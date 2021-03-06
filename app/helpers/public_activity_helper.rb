class PublicActivity::Activity

  scope :oldest_first,  -> { order(created_at: :asc) }
  scope :newest_first,  -> { order(created_at: :desc) }
  scope :between,       ->(s,e) { where("created_at >= ?", s)
                                 .where("created_at < ?", e) }
  scope :of_last_x_hours, ->(h){ between(Time.current - h.hours, Time.current) }
  scope :of_last_24_hours, -> { of_last_x_hours(24) }
  scope :of_yesterday,     -> { between( Date.yesterday.at_beginning_of_day,
                                         Date.yesterday.at_end_of_day,) }

  scope :of_visibility, ->(v) { where(visibility: v) }
  scope :of_severity,   ->(v) { where(severity: v) }
  scope :of_scope,      ->(v) { where(scope: v) }

  # We use '#{owner_type} #{owner_id}' instead of '#{owner}' (and so on)
  # because '#{owner}' requires a call to the DB, and it makes sense
  # that #to_s methods can return without relying on the DB.
  def to_s
    "Activity #{id.inspect}: #{key.inspect}" +
    " owned by #{owner_type.inspect}:#{owner_id.inspect}" +
    " for model #{trackable_type.inspect}:#{trackable_id.inspect}" +
    " (scope: #{scope.inspect}, severity: #{severity.inspect}," +
    " visibility: #{visibility.inspect})"
  end

  # Like #to_s but using '#{owner}' (which requires a call to the DB to
  # retrieve the full object) instead of only '#{owner_type} #{owner_id}'
  # (and so on) to provide more details.
  def to_s_detailed
    "Activity #{id}\n" +
    "    Key:        '#{key}'\n" +
    "    Date:       #{created_at}\n" +
    "    Owner:      '#{owner}'\n" +
    "    Model:      '#{trackable}'\n" +
    "    Recipient:  '#{recipient}'\n" +
    "    scope:      '#{scope}'\n" +
    "    severity:   '#{severity}'\n" +
    "    visibility: '#{visibility}'"
  end
end

module PublicActivityHelper

  class Scope < Enum
    enum :EMAIL
    enum :JOB
    enum :DEPOT
    enum :SUBSCRIPTION
    enum :MODEL
    enum :SECURITY
  end

  class Visibility < Enum
    enum :PUBLIC
    enum :ACTIVITY_USERS
    enum :ACTIVITY_OWNER
    enum :ADMIN
  end

  class Severity < Enum
    enum :LOW
    enum :MEDIUM
    enum :HIGH
    enum :CRITICAL
  end

  def record_activity(activity_name, model, data: {}, owner: nil)
    raise "Activity name must be a symbol" unless activity_name.is_a? Symbol
    raise "Model cannot not be nil" unless model
    unless model.respond_to? :create_activity
      raise "Model of class '#{model.class}' must respond to" +
            " :create_activity. Please ensure it includes" +
            " the 'PublicActivity::Common' module."
    end
    flags = activity_flags activity_name
    unless flags.map(&:class) == [Scope, Visibility, Severity]
      raise "Unexpected flags for activity: #{flags.inspect} of classes " +
            "#{flags.map(&:class)}"
    end
    scope, visibility, severity = flags
    trackable_model = model
    owner_model     = owner || try(:current_user)
    recipient_model = nil
    parameters      = data.merge({
        # Keep a denormalized string trace of the relations of this activity for
        # the case those are deleted later.
        trackable:  trackable_model,
        owner:      owner_model,
        recipient:  recipient_model
      })
    # Customize parameters depending on scope
    case scope
    when Scope::SECURITY
      parameters[:request_remote_ip] = request.remote_ip_and_address
      parameters[:request_user_agent] = request.user_agent
    when Scope::EMAIL
      parameters[:to] = trackable_model.try(:email)
    end
    # Customize parameters and behavior depending on activity_name
    case activity_name
    when :send_job_reminder
      recipient_model = parameters[:recipient] = parameters.pop(:job)
      unless owner_model
        parameters[:owner] = "rake_task"
        parameters[:rake_task] = "send_reminders_for_tomorrow_jobs"
      end
    when :user_login
      trackable_model.record_last_login from: parameters[:remote_ip]
    when :create
      case trackable_model
      when ShareCertificate
        recipient_model = parameters[:recipient] = trackable_model.user
      end
    when :update, :destroy
      last_version = trackable_model.versions.last
      parameters[:previous_version_id] = last_version.try(:id)
      parameters[:changeset] = last_version.try(:changeset)
    when :admin_sign_up_user_for_job,
         :admin_sign_up_user_for_job_failed,
         :admin_cancel_job_signup
      recipient_model = parameters[:recipient] = parameters.pop(:user)
    end

    # NOTE: Playing with PublicActivity::Activity API, we've learned two things:
    #
    #   - If a parameter value in the 'parameters' hash is a symbol,
    #     PublicActivity will call it on the 'owner' object when creating the
    #     activity, e.g.: parameters[:the_email] = :email becomes
    #     parameters[:the_email] = owner.email when the activity is created. If
    #     the owner object does not respond to the symbol, an exception will be
    #     thrown upon activity recording.
    #
    #   - In order to let ruby deserialize a nested object when loading an
    #     active record from the DB, the corresponding (compatible) class MUST
    #     be loaded in order for the object to be deserialized. Otherwize an
    #     Exception is raised. (Still to check: what happens if the class has
    #     changed since the object was serialized?)
    #
    # Therefore, to prevent such complications, we don't store real
    # objects in the parameters, which would be automatically serialized
    # as yaml by rails and deserialized (aka reified) automatically upon
    # ActiveRecord load from the DB. We only store the result of calling
    # :to_s as quick human reference when reading the activity back from
    # the DB. A possible enhancement would be to serialize only ruby
    # native types (hash, set, array, symbol and so on), so that they can
    # be read upon Activity load but then, it would be difficult to ensure
    # that no other object is nested inside.

    # Make sure all parameter values are strings (not objects) since they are
    # not expected to be reified when reading the activity and would fail.
    parameters.each { |k, v| parameters[k] = v && v.to_s }

    activity = trackable_model.create_activity activity_name,
                                               owner: owner_model,
                                               recipient: recipient_model,
                                               scope: scope.to_s,
                                               visibility: visibility.to_s,
                                               severity: severity.to_s,
                                               parameters: parameters
    logger.info "Recorded #{activity}"

    if Rails.env.production? &&
       [Severity::HIGH, Severity::CRITICAL].include?(severity)
      AdminMailer.activity_warning_notification(activity).deliver_later
    end
  end

  private

    # Returns a vector of the three activity identifiers:
    # [:scope, :visibility, :severity]
    # :scope       => E.g.: security, email, job, user, ...
    # :visibility  => admin, activity owner, activity users, public
    # :severity    => low, medium, high, critical
    def activity_flags(activity_name)
      case activity_name
      when :create,
           :update
        [Scope::MODEL, Visibility::ACTIVITY_USERS, Severity::LOW]
      when :destroy,
           :destroy_failed,
           :cancel
        [Scope::MODEL, Visibility::ACTIVITY_USERS, Severity::MEDIUM]
      when :send_job_reminder,
           :send_job_canceled_notification,
           :send_job_signup_canceled_notification,
           :send_new_job_signup_by_admin_confirmation,
           :send_new_self_job_signup_confirmation
        [Scope::EMAIL, Visibility::ACTIVITY_USERS, Severity::LOW]
      when :send_signup_successful_notification,
           :send_new_signup_notification,
           :send_account_activation
        [Scope::EMAIL, Visibility::ADMIN, Severity::LOW]
      when :send_login_code_email
        [Scope::EMAIL, Visibility::ACTIVITY_USERS, Severity::MEDIUM]
      when :new_user_signup
        [Scope::SECURITY, Visibility::ADMIN, Severity::LOW]
      when :inactive_user_tries_to_login,
           :user_login_attempt_fail,
           :user_login_code_expired
        [Scope::SECURITY, Visibility::ADMIN, Severity::MEDIUM]
      when :user_login_all_attempts_fail
        [Scope::SECURITY, Visibility::ADMIN, Severity::HIGH]
      when :new_admin_user_created,
           :user_promoted_from_normal_user_to_admin,
           :user_demoted_from_admin_to_normal_user
        [Scope::SECURITY, Visibility::ADMIN, Severity::HIGH]
      when :login_attempt_from_unexpected_ip
        [Scope::SECURITY, Visibility::ADMIN, Severity::CRITICAL]
      when :user_login,
           :user_logout
        [Scope::SECURITY, Visibility::ACTIVITY_OWNER, Severity::MEDIUM]
      when :current_user_sign_up_for_job,
           :admin_sign_up_user_for_job
        [Scope::JOB, Visibility::PUBLIC, Severity::LOW]
      when :admin_cancel_job_signup
        [Scope::JOB, Visibility::ACTIVITY_USERS, Severity::MEDIUM]
      when :current_user_sign_up_for_job_failed,
           :admin_sign_up_user_for_job_failed,
           :admin_cancel_job_signup_failed
        [Scope::JOB, Visibility::ADMIN, Severity::MEDIUM]
      when :admin_cancel_depot_coordinator,
           :planned_depot_change
        [Scope::DEPOT, Visibility::ACTIVITY_USERS, Severity::MEDIUM]
      when :planned_items_list_modified,
           :current_items_list_modified
        [Scope::SUBSCRIPTION, Visibility::ACTIVITY_USERS, Severity::MEDIUM]
      else
        raise "Unknown activity name: #{activity_name}"
      end
    end

end

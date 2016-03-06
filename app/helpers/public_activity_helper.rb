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
    "Activity #{id}: '#{key}'" +
    " owned by '#{owner_type} #{owner_id}'" +
    " for model '#{trackable_type} #{trackable_id}'" +
    " (scope: #{scope}, severity: #{severity}, visibility: #{visibility})"
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

  def record_activity(activity_name, model, data: {})
    raise "Activity name must be a symbol" unless activity_name.is_a? Symbol
    raise "Model cannot not be nil" unless model
    unless model.respond_to? :create_activity
      raise "Model of class '#{model.class}' must respond to" +
            " :create_activity. Please ensure it includes" +
            " the 'PublicActivity::Common' module."
    end
    scope, visibility, severity = activity_flags activity_name
    trackable_model = model
    owner_model     = try(:current_user)
    recipient_model = nil
    parameters      = data.merge({
        # Keep a denormalized serialized trace of the relations of this activity
        # for the case those are deleted later.
        trackable:  trackable_model,
        owner:      owner_model,
        recipient:  recipient_model
      })
    # Customize parameters depending on scope
    case scope
    when :security
      parameters[:request_remote_ip] = request.remote_ip_and_address
      parameters[:request_user_agent] = request.user_agent
    when :email
      parameters[:to] = trackable_model.try(:email)
    end
    # Customize parameters and behavior depending on activity_name
    case activity_name
    when :send_job_reminder
      recipient_model = parameters[:recipient] = parameters.pop(:job)
      unless owner_model
        parameters[:owner] = :rake_task
        parameters[:rake_task] = :send_reminders_for_tomorrow_jobs
      end
    when :user_login
      trackable_model.record_last_login from: parameters[:remote_ip]
    when :created
      case trackable_model
      when ShareCertificate
        recipient_model = parameters[:recipient] = trackable_model.user
      end
    when :updated, :destroy
      last_version = trackable_model.versions.last
      parameters[:previous_version_id] = last_version.try(:id)
      parameters[:changeset] = last_version.try(:changeset)
    when :admin_sign_up_user_for_job, :admin_sign_up_user_for_job_failed
      recipient_model = parameters[:recipient] = parameters.pop(:user)
    end
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

    if Rails.env.production? && [:high, :critical].include?(severity)
      AdminMailer.activity_warning_notification(activity).deliver_later
    end
  end

  private

    # Returns a vector of the three activity identifiers:
    # [:scope, :visibility, :severity]
    # :scope       => E.g.: :security, :email, :job, :user, ...
    # :visibility  => :admin, :activity_owner, :activity_users, :public
    # :severity    => :low, :medium, :high, :critical
    def activity_flags(activity_name)
      case activity_name
      when :create
        [:model, :activity_users, :low]
      when :update
        [:model, :activity_users, :low]
      when :destroy
        [:model, :activity_users, :medium]
      when :send_job_reminder
        [:email, :activity_users, :low]
      when :send_signup_successful_notification,
           :send_new_signup_notification,
           :send_account_activation
        [:email, :admin, :low]
      when :send_login_code_email
        [:email, :activity_users, :medium]
      when :new_user_signup
        [:security, :admin, :low]
      when :inactive_user_tries_to_login,
           :user_login_attempt_fail,
           :user_login_code_expired
        [:security, :admin, :medium]
      when :user_login_all_attempts_fail
        [:security, :admin, :high]
      when :login_attempt_from_unexpected_ip
        [:security, :admin, :critical]
      when :user_login,
           :user_logout
        [:security, :activity_owner, :medium]
      when :current_user_sign_up_for_job,
           :admin_sign_up_user_for_job
        [:job, :public, :low]
      when :current_user_sign_up_for_job_failed,
           :admin_sign_up_user_for_job_failed
        [:job, :admin, :medium]
      else
        raise "Unknown activity name: #{activity_name}"
      end
    end

end

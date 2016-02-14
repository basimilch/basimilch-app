module PublicActivityHelper

  def record_activity(activity, model, data: {})
    raise "Activity must be a symbol" unless activity.is_a? Symbol
    raise "Model cannot not be nil" unless model
    unless model.respond_to? :create_activity
      raise "Model of class '#{model.class}' must respond to" +
            " :create_activity. Please ensure it includes" +
            " the 'PublicActivity::Common' module."
    end
    scope, visibility, severity = activity_flags activity
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
    # Customize parameters and behavior depending on activity
    case activity
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
    end
    # Make sure all parameter values are strings (not objects) since they are
    # not expected to be reified when reading the activity and would fail.
    parameters.each { |k, v| parameters[k] = v && v.to_s }
    logger.info "Recording #{scope} activity #{activity}" +
                " owned by #{owner_model.inspect}" +
                " for model #{trackable_model}" +
                " (severity: #{severity}, visibility: #{visibility})"
    trackable_model.create_activity activity, owner: owner_model,
                                              recipient: recipient_model,
                                              scope: scope.to_s,
                                              visibility: visibility.to_s,
                                              severity: severity.to_s,
                                              parameters: parameters
  end

  private

    # Returns a vector of the three activity identifiers:
    # [:scope, :visibility, :severity]
    # :scope       => E.g.: :security, :email, :job, :user, ...
    # :visibility  => :admin, :activity_owner, :activity_users, :public
    # :severity    => :low, :medium, :high, :critical
    def activity_flags(activity)
      case activity
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
      when :user_login
        [:security, :activity_owner, :medium]
      when :current_user_sign_up_for_job
        [:job, :public, :low]
      when :current_user_can_not_sign_up_for_job
        [:job, :admin, :medium]
      else
        raise "Unknown activity: #{activity}"
      end
    end

end

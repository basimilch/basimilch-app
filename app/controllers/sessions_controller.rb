class SessionsController < ApplicationController

  LOGIN_CODE_VALIDITY = 5.minutes
  MAX_LOGIN_ATTEMPTS  = 3

  before_action :require_no_logged_in_user,  except: [:destroy]

  def new
    forget_login_attempt
    if logged_in?
      redirect_to profile_path
    end
    @email = params[:email]
  end

  def validation
    if params[:session][:email].blank?
      render 'new'
      return
    end
    @user = User.find_by(email: params[:session][:email].downcase.squish)
    if not @user
      logger.info "Login User not found: #{params[:session][:email]} " +
                  "(from IP: request.remote_ip.inspect)"
      flash_now_t :danger, :user_not_found
      render 'new'
    elsif not @user.allowed_to_login?
      logger.info "Login User inactive: #{@user.email} " +
                  "(from IP: request.remote_ip.inspect)"
      flash_now_t :danger, :user_inactive
      render 'new'
    elsif !login_code_sent?
      # Active user found, send login code
      login_code = rand_validation_code
      remember_login_attempt_for @user,
                                 login_code.number,
                                 params[:session][:secure_computer_acknowledged]
      send_login_code_email @user, login_code
      if @user.never_logged_in?
        flash_now_t :success, t(".first_login_attempt_html", email: @user.email)
      end
      flash_now_t :info, t(".login_code_email_sent_html", email: @user.email)
    end
  end

  def create_with_login_code(login_code)
    if session[:login_email].blank?
      logger.warn "Login attempt with no email in the session cookie."
      flash_t :danger, :email_not_found_in_session
      redirect_to login_path
      return
    end
    @user = User.find_by(email: session[:login_email].downcase)
    if not @user
      # NOTE: Should not happen. Maybe tampering with the cookies or the user
      #       got deleted in the meantime.
      logger.warn "Login attempt but the email in the session cookie does not" +
                  " match any user: '#{session[:login_email].downcase}'."
      flash_t :danger, :weird_login_problem
      redirect_to login_path
      return
    elsif !@user.allowed_to_login?
      # NOTE: Should not happen. Maybe tampering with the cookies or the user
      #       got deactivated in the meantime.
      logger.warn "Login attempt but the user from the email in the session" +
                  " cookie appears as not active:" +
                  "'#{session[:login_email].downcase}'."
      flash_t :danger, :weird_login_problem
      redirect_to login_path
      return
    elsif request.remote_ip.inspect != session[:login_ip]
      logger.warn "Login attemps from unexpected IP " +
                   "#{request.remote_ip.inspect}: #{result.inspect}"
      logger.warn "Expected IP was #{session[:login_ip]}"
      flash_t :danger, :not_the_expected_ip_address
      redirect_to login_path
      return
    end
    if login_code_expired?
      flash_t :danger, t(".login_code_expired",
                         login_code_validity: LOGIN_CODE_VALIDITY.in_words)
      logger.warn "Login Code expired for user #{@user.email}" +
                    "LOGIN CODES ARE ONLY VALID #{LOGIN_CODE_VALIDITY} seconds."
      redirect_to login_path
      return
    end
    if session[:login_code].is_secure_temp_digest_for?(login_code)
      # Everything looks right: let's log in the user
      log_in @user # @user becomes current_user
      if current_user.never_logged_in?
        current_user.activate
        flash_t :success, :first_login_successful_html
      end
      session[:secure_computer_acknowledged] == '0' ? forget(current_user)
                                                    : remember(current_user)
      forget_login_attempt
      redirect_back_or profile_path
      return
    else
      # Wrong login code
      increase_login_attempts
      if remaining_login_attempts > 0
        logger.warn "Failed logging attempt for user '#{@user.email}'. " +
                    "REMAINING ATTEMPS: #{remaining_login_attempts}"
        flash_now_t :danger, t(".wrong_login_code",
                               remaining_attempts: remaining_login_attempts)
        render 'validation'
      else
        logger.warn "Max number of failed logging attempts " +
                    "(#{MAX_LOGIN_ATTEMPTS}) for user '#{@user.email}'" +
                    " reached from IP #{request.remote_ip.inspect}."
        flash_t :danger, :wrong_login_code_no_more_attempts
        redirect_to login_path
        return
      end
    end
  end

  def create_from_url
    create_with_login_code params[:code]
  end

  def create
    create_with_login_code entered_login_code
  end

  def destroy
    log_out if logged_in?
    redirect_to login_url
  end

  private

    def remember_login_attempt_for(user, login_code, secure_computer_acknowledged)
      logger.debug "Remember login attemp for user '#{user && user.email}'"
      session[:login_email] = user.email
      session[:login_ip]    = request.remote_ip.inspect
      session[:login_code]  = login_code.number.secure_temp_digest
      session[:login_expiration_date]         = LOGIN_CODE_VALIDITY.from_now
      session[:login_attempts]                = 0
      session[:secure_computer_acknowledged]  = secure_computer_acknowledged
    end

    def login_code_sent?
      not session[:login_code].blank?
    end

    def forget_login_attempt
      logger.debug "Forget login attemp for user '#{session[:login_email]}'"
      session[:login_email]                   = nil
      session[:login_ip]                      = nil
      session[:login_code]                    = nil
      session[:login_expiration_date]         = nil
      session[:login_attempts]                = nil
      session[:secure_computer_acknowledged]  = nil
      cookies.delete(:login_email)
      cookies.delete(:login_ip)
      cookies.delete(:login_code)
      cookies.delete(:login_expiration_date)
      cookies.delete(:login_attempts)
      cookies.delete(:secure_computer_acknowledged)
    end

    def increase_login_attempts
      session[:login_attempts] = session[:login_attempts] + 1
    end

    def remaining_login_attempts
      MAX_LOGIN_ATTEMPTS - session[:login_attempts]
    end

    def send_login_code_email(user, login_code)
      UserMailer.login_code(user, login_code, LOGIN_CODE_VALIDITY)
                .deliver_now
    end

    def entered_login_code
      params.require(:login_code_form)[:login_code].number
    end

    def login_code_expired?
      logger.debug "Logging expiration: #{session[:login_expiration_date].to_time}"
      logger.debug "Current:            #{Time.current}"
      session[:login_expiration_date].to_time < Time.current
    end

end

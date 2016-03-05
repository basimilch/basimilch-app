module UsersHelper

  PERMITTED_ATTRIBUTES = [:first_name,
                          :last_name,
                          :email,
                          :postal_address,
                          :postal_address_supplement,
                          :postal_code,
                          :city,
                          # :country,
                          :tel_mobile,
                          :tel_mobile_formatted,
                          :tel_home,
                          :tel_home_formatted,
                          :tel_office,
                          :tel_office_formatted,
                          :terms_of_service,
                          :wanted_number_of_share_certificates,
                          :wanted_subscription]

  def user_params
    # Pattern 'strong parameters' to secure form input.
    # Source:
    #   https://www.railstutorial.org/book/_single-page#sec-strong_parameters
    params.require(:user).permit(PERMITTED_ATTRIBUTES +
                (current_user_admin?                        ? [:admin] : []) +
                (current_user_admin? || current_user.blank? ? [:notes] : []))
  end

  def query_params
    params.permit(PERMITTED_ATTRIBUTES)
  end

  # Returns the option tags to select the number of share certificates that the
  # new user wants during self-signup. Used in the user/_form partial.
  def options_for_wanted_share_certificates
    options_for_select(
      User::ALLOWED_NUMBER_OF_WANTED_SHARE_CERTIFICATES.map do |n|
        ["#{n} (#{t '.total_price', price: ShareCertificate::UNIT_PRICE * n})", n]
      end,
      @user.wanted_number_of_share_certificates
      )
  end

  # Returns the option tags to select the subscription option that the
  # new user wants during self-signup. Used in the user/_form partial.
  def options_for_wanted_subscription
    options_for_select(
      User::ALLOWED_WANTED_SUBSCRIPTION_OPTIONS.map do |status|
        [t(".wanted_subscription.#{status}"), status]
      end,
      @user.wanted_subscription
      )
  end
end

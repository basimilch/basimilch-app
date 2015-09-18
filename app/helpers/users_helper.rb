module UsersHelper

  PERMITTED_ATTRIBUTES = [:first_name,
                          :last_name,
                          :email,
                          :postal_address,
                          :postal_code,
                          :city,
                          # :country,
                          :tel_mobile,
                          :tel_mobile_formatted,
                          :tel_home,
                          :tel_home_formatted,
                          :tel_office,
                          :tel_office_formatted,
                          :notes]

  def user_params
    # Pattern 'strong parameters' to secure form input.
    # Source:
    #   https://www.railstutorial.org/book/_single-page#sec-strong_parameters
    params.require(:user).permit(PERMITTED_ATTRIBUTES +
                                        (current_user_admin? ? [:admin] : []))
  end

  def query_params
    params.permit(PERMITTED_ATTRIBUTES)
  end
end

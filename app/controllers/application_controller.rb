class ApplicationController < ActionController::Base

  require 'csv'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include PublicActivityHelper
  include ApplicationHelper
  include ActionFilterHelper
  include CancelableHelper
  include SessionsHelper
  include UsersHelper

  # PaperTrail 5 no longer adds the set_paper_trail_whodunnit callback
  # automatically. To continue recording whodunnit, we have to add
  # this before_action callback to the ApplicationController.
  # DOC: https://github.com/airblade/paper_trail/blob/v5.1.1/doc/warning_about_not_setting_whodunnit.md
  # DOC: https://github.com/airblade/paper_trail/tree/v5.1.1#4a-finding-out-who-was-responsible-for-a-change
  before_filter :set_paper_trail_whodunnit

  # DOC: https://github.com/airblade/paper_trail/tree/v5.1.1#metadata-from-controllers
  def info_for_paper_trail
    { request_remote_ip:  request.remote_ip,
      request_user_agent: request.user_agent }
  end
end

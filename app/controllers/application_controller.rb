class ApplicationController < ActionController::Base

  require 'csv'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include PublicActivityHelper
  include ApplicationHelper
  include ActionFilterHelper
  include SessionsHelper
  include UsersHelper

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#metadata-from-controllers
  def info_for_paper_trail
    { request_remote_ip:  request.remote_ip,
      request_user_agent: request.user_agent }
  end
end

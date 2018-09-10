class ErrorsController < ApplicationController

  def show
    error_codes = Rails.configuration.error_codes_with_custom_view
    @status_code = error_codes.detect{ |c| c.to_s == params[:code].to_s } || 500
    render status: @status_code
  end
end

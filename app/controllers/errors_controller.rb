class ErrorsController < ApplicationController

  ERROR_CODES = [404, 500]

  def show
    @status_code = ERROR_CODES.detect{ |c| c.to_s == params[:code].to_s } || 500
    render status: @status_code
  end
end

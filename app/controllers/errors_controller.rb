# app/controllers/errors_controller.rb
class ErrorsController < ApplicationController
  layout false

  def server_error
    render status: :internal_server_error
  end
end

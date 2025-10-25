class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def csrf
    render json: { csrf_token: form_authenticity_token }
  end
end

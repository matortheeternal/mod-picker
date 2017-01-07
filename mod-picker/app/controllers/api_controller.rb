class ApiController < ApplicationController
  # GET /api/security_token
  def security_token
    render json: { token: form_authenticity_token }
  end
end
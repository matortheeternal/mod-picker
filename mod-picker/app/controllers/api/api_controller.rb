class Api::ApiController < ActionController::Base
  before_filter :verify_api_token

  def verify_api_token
    @api_token = ApiToken.find_by(expired: false, api_key: params[:api_key])
    if @api_token.present?
      @api_token.increment_requests!
    else
      render json: { error: "Your API key is invalid." }, status: 401
    end
  end

  def current_ability
    @current_ability ||= Ability.new(nil)
  end
end
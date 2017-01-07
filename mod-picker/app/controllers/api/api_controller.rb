class Api::ApiController < ActionController::Base
  before_filter :verify_api_token

  def verify_api_token
    @api_token = ApiToken.find_by(active: true, api_key: params[:api_key])
    @api_token.increment_requests! if @api_token.present?
    @api_token.present?
  end

  def current_ability
    @current_ability ||= Ability.new(nil)
  end
end
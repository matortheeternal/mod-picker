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

  def json_format(resource, format=nil)
    format ||= action_name.to_sym
    resource.as_json(format: format)
  end

  def respond_with_json(resource, format=nil, root=nil)
    format ||= action_name.to_sym
    resource_json = resource.as_json(format: format)
    render json: root ? { root => resource_json } : resource_json
  end
end
class ApiTokensController < ApplicationController
  before_action :set_api_token, only: [:update, :expire]

  # POST /api_tokens
  def create
    @api_token = ApiToken.new(api_token_params)
    @api_token.user_id = current_user.id
    authorize! :create, @api_token

    if @api_token.save
      respond_with_json(@api_token, :base, :api_token)
    else
      render json: @api_token.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api_tokens/1
  def update
    authorize! :update, @api_token, message: "You are not allowed to edit this api token"
    if @api_token.update(api_token_params)
      render json: {status: :ok}
    else
      render json: @api_token.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api_tokens/1
  def expire
    authorize! :expire, @api_token
    if @api_token.expire!
      render json: {status: :ok}
    else
      render json: @api_token.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_token
      @api_token = ApiToken.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def api_token_params
      params.require(:api_token).permit(:name)
    end
end
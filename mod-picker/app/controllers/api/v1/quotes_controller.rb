class Api::V1::QuotesController < Api::ApiController
  # GET /quotes
  def index
    render json: Quote.all
  end
end

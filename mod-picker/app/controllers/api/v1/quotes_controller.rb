class Api::V1::QuotesController < Api::ApiController
  # GET /quotes
  def index
    render json: static_cache("quotes") {
      Quote.all.to_json
    }
  end
end

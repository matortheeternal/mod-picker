class QuotesController < ApplicationController
  # GET /quotes
  def index
    render json: static_cache("quotes") {
      Quote.all.to_json
    }
  end
end

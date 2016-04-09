class QuotesController < ApplicationController
  # GET /quotes
  # GET /quotes.json
  def index
    @quotes = Quote.all

    render :json => @quotes
  end
end

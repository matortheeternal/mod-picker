class QuotesController < ApplicationController
  # GET /quotes
  def index
    render :json => Quote.all
  end
end

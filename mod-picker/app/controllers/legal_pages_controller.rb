class LegalPagesController < ApplicationController
  layout "legal"

  def index
    render "legal_pages/tos"
  end

  def tos
  end

  def privacy
  end

  def copyright
  end
end
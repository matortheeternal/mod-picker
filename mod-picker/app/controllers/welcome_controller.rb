class WelcomeController < ApplicationController
  def index
    render layout: "landing"
  end
end

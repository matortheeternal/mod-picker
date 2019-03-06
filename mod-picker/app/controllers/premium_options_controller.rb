class PremiumOptionsController < ApplicationController
  def index
    render json: static_cache("premium_options") {
      PremiumOption.all.to_json
    }
  end
end
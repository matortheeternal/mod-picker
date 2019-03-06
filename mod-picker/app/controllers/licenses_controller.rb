class LicensesController < ApplicationController
  def index
    render json: static_cache("licenses") {
      License.includes(:license_options).to_json({format: "index"})
    }
  end
end
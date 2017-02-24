class LicensesController < ApplicationController
  def index
    @licenses = License.includes(:license_options)
    respond_with_json(@licenses)
  end
end
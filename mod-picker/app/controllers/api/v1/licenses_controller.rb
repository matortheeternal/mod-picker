class LicensesController < Api::ApiController
  def index
    @licenses = License.includes(:license_options)
    respond_with_json(@licenses, nil, :licenses)
  end
end
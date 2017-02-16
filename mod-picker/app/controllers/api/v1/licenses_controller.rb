class LicensesController < Api::ApiController
  def index
    respond_with_json(License.all, nil, :licenses)
  end
end
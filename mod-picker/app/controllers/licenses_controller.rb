class LicensesController < ApplicationController
  def index
    respond_with_json(License.all, nil, :licenses)
  end
end
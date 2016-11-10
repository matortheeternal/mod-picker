class TagsController < ApplicationController
  before_action :set_tag, only: [:destroy]

  # GET /tags
  def index
    @tags = Tag.filter(filtering_params)
    render json: @tags
  end

  # DELETE /mods/1
  def destroy
    authorize! :destroy, @tag
    if @tag.destroy
      render json: {status: :ok}
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tag
      @tag = Tag.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:game);
    end
end
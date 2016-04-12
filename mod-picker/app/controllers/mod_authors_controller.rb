class ModAuthorsController < ApplicationController
  before_action :set_mod_author, only: [:create, :destroy]

  # POST /mod_authors
  # POST /mod_authors.json
  def create
    @mod_author = ModAuthor.new(mod_author_params)

    respond_to do |format|
      if @mod_author.save
        format.json { render :show, status: :created, location: @mod_author }
      else
        format.json { render json: @mod_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_authors/1
  # DELETE /mod_authors/1.json
  def destroy
    @mod_author.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_author
      @mod_author = ModAuthor.find_by(mod_id: params[:mod_id], user_id: params[:user_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_author_params
      params.require(:mod_author).permit(:mod_id, :user_id)
    end
end

class ModAuthorsController < ApplicationController
  before_action :set_user_mod_author_map, only: [:show, :edit, :update, :destroy]

  # GET /mod_authors
  # GET /mod_authors.json
  def index
    @user_mod_author_maps = ModAuthor.all
  end

  # GET /mod_authors/1
  # GET /mod_authors/1.json
  def show
  end

  # GET /mod_authors/new
  def new
    @user_mod_author_map = ModAuthor.new
  end

  # GET /mod_authors/1/edit
  def edit
  end

  # POST /mod_authors
  # POST /mod_authors.json
  def create
    @user_mod_author_map = ModAuthor.new(user_mod_author_map_params)

    respond_to do |format|
      if @user_mod_author_map.save
        format.html { redirect_to @user_mod_author_map, notice: 'User mod author map was successfully created.' }
        format.json { render :show, status: :created, location: @user_mod_author_map }
      else
        format.html { render :new }
        format.json { render json: @user_mod_author_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_authors/1
  # PATCH/PUT /mod_authors/1.json
  def update
    respond_to do |format|
      if @user_mod_author_map.update(user_mod_author_map_params)
        format.html { redirect_to @user_mod_author_map, notice: 'User mod author map was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_mod_author_map }
      else
        format.html { render :edit }
        format.json { render json: @user_mod_author_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_authors/1
  # DELETE /mod_authors/1.json
  def destroy
    @user_mod_author_map.destroy
    respond_to do |format|
      format.html { redirect_to user_mod_author_maps_url, notice: 'User mod author map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_mod_author_map
      @user_mod_author_map = ModAuthor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_mod_author_map_params
      params.require(:user_mod_author_map).permit(:mod_id, :user_id)
    end
end

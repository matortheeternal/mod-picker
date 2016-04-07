class ModListsController < ApplicationController
  before_action :set_mod_list, only: [:show, :edit, :update, :destroy]

  # GET /mod_lists
  # GET /mod_lists.json
  def index
    @mod_lists = ModList.all

    respond_to do |format|
      format.html
      format.json { render :json => @mod_lists}
    end
  end

  # GET /mod_lists/1
  # GET /mod_lists/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @mod_list}
    end
  end

  # GET /mod_lists/new
  def new
    @mod_list = ModList.new
  end

  # GET /mod_lists/1/edit
  def edit
  end

  # POST /mod_lists
  # POST /mod_lists.json
  def create
    @mod_list = ModList.new(mod_list_params)

    respond_to do |format|
      if @mod_list.save
        format.json { render :show, status: :created, location: @mod_list }
      else
        format.json { render json: @mod_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_lists/1
  # PATCH/PUT /mod_lists/1.json
  def update
    respond_to do |format|
      if @mod_list.update(mod_list_params)
        format.json { render :show, status: :ok, location: @mod_list }
      else
        format.json { render json: @mod_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_lists/1
  # DELETE /mod_lists/1.json
  def destroy
    @mod_list.destroy
    respond_to do |format|
      format.json { render json: { status: :ok } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list
      @mod_list = ModList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_params
      params.require(:mod_list).permit(:game_id, :name, :created_by, :is_collection, :is_public, :has_adult_content, :status, :created, :completed, :description)
    end
end

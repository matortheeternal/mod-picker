class ModAuthorsController < ApplicationController
  before_action :set_mod_author, only: [:show, :edit, :update, :destroy]

  # GET /mod_authors
  # GET /mod_authors.json
  def index
    @mod_authors = ModAuthor.all

    respond_to do |format|
      format.html
      format.json { render :json => @mod_authors}
    end
  end

  # GET /mod_authors/1
  # GET /mod_authors/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @mod_author}
    end
  end

  # GET /mod_authors/new
  def new
    @mod_author = ModAuthor.new
  end

  # GET /mod_authors/1/edit
  def edit
  end

  # POST /mod_authors
  # POST /mod_authors.json
  def create
    @mod_author = ModAuthor.new(mod_author_params)

    respond_to do |format|
      if @mod_author.save
        format.html { redirect_to @mod_author, notice: 'User mod author map was successfully created.' }
        format.json { render :show, status: :created, location: @mod_author }
      else
        format.html { render :new }
        format.json { render json: @mod_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_authors/1
  # PATCH/PUT /mod_authors/1.json
  def update
    respond_to do |format|
      if @mod_author.update(mod_author_params)
        format.html { redirect_to @mod_author, notice: 'User mod author map was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_author }
      else
        format.html { render :edit }
        format.json { render json: @mod_author.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_authors/1
  # DELETE /mod_authors/1.json
  def destroy
    @mod_author.destroy
    respond_to do |format|
      format.html { redirect_to mod_authors_url, notice: 'User mod author map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_author
      @mod_author = ModAuthor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_author_params
      params.require(:mod_author).permit(:mod_id, :user_id)
    end
end

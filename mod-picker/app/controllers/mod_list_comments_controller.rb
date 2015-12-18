class ModListCommentsController < ApplicationController
  before_action :set_mod_list_comment, only: [:show, :edit, :update, :destroy]

  # GET /mod_list_comments
  # GET /mod_list_comments.json
  def index
    @mod_list_comments = ModListComment.all
  end

  # GET /mod_list_comments/1
  # GET /mod_list_comments/1.json
  def show
  end

  # GET /mod_list_comments/new
  def new
    @mod_list_comment = ModListComment.new
  end

  # GET /mod_list_comments/1/edit
  def edit
  end

  # POST /mod_list_comments
  # POST /mod_list_comments.json
  def create
    @mod_list_comment = ModListComment.new(mod_list_comment_params)

    respond_to do |format|
      if @mod_list_comment.save
        format.html { redirect_to @mod_list_comment, notice: 'Mod list comment was successfully created.' }
        format.json { render :show, status: :created, location: @mod_list_comment }
      else
        format.html { render :new }
        format.json { render json: @mod_list_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_list_comments/1
  # PATCH/PUT /mod_list_comments/1.json
  def update
    respond_to do |format|
      if @mod_list_comment.update(mod_list_comment_params)
        format.html { redirect_to @mod_list_comment, notice: 'Mod list comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_list_comment }
      else
        format.html { render :edit }
        format.json { render json: @mod_list_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_list_comments/1
  # DELETE /mod_list_comments/1.json
  def destroy
    @mod_list_comment.destroy
    respond_to do |format|
      format.html { redirect_to mod_list_comments_url, notice: 'Mod list comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_comment
      @mod_list_comment = ModListComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_comment_params
      params.require(:mod_list_comment).permit(:ml_id, :c_id)
    end
end

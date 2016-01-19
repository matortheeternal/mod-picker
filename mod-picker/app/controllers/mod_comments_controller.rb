class ModCommentsController < ApplicationController
  before_action :set_mod_comment, only: [:show, :edit, :update, :destroy]

  # GET /mod_comments
  # GET /mod_comments.json
  def index
    @mod_comments = ModComment.all
  end

  # GET /mod_comments/1
  # GET /mod_comments/1.json
  def show
  end

  # GET /mod_comments/new
  def new
    @mod_comment = ModComment.new
  end

  # GET /mod_comments/1/edit
  def edit
  end

  # POST /mod_comments
  # POST /mod_comments.json
  def create
    @mod_comment = ModComment.new(mod_comment_params)

    respond_to do |format|
      if @mod_comment.save
        format.html { redirect_to @mod_comment, notice: 'Mod comment was successfully created.' }
        format.json { render :show, status: :created, location: @mod_comment }
      else
        format.html { render :new }
        format.json { render json: @mod_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_comments/1
  # PATCH/PUT /mod_comments/1.json
  def update
    respond_to do |format|
      if @mod_comment.update(mod_comment_params)
        format.html { redirect_to @mod_comment, notice: 'Mod comment was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_comment }
      else
        format.html { render :edit }
        format.json { render json: @mod_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_comments/1
  # DELETE /mod_comments/1.json
  def destroy
    @mod_comment.destroy
    respond_to do |format|
      format.html { redirect_to mod_comments_url, notice: 'Mod comment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_comment
      @mod_comment = ModComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_comment_params
      params.require(:mod_comment).permit(:mod_id, :comment_id)
    end
end

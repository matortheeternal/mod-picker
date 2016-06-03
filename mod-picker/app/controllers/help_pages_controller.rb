class HelpPagesController < ApplicationController
  before_action :set_help_page, only: [:show, :edit, :update, :destroy]
  layout 'help'

  # GET /help
  def index
  end

  # GET /help/1
  def show
  end

  # GET /help/new
  def new
  end

  # GET /help/1/edit
  def edit
  end

  # POST /help/1
  def create
    @help_page = HelpPage.new(help_page_params)
    authorize! :create, @help_page
    if @help_page.save
      render json: {status: :ok}
    else
      render json: @help_page.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /help/1
  def update
    authorize! :update, @help_page
    if @help_page.update(help_page_params)
      render json: {status: :ok}
    else
      render json: @help_page.errors, status: :unprocessable_entity
    end
  end

  # DELETE /help/1
  def destroy
    authorize! :destroy, @help_page
    if @help_page.destroy
      redirect_to help_url, notice: 'Help Page was successfully destroyed.'
    else
      render :show
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_help_page
      @help_page = HelpPage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def help_page_params
      params.require(:help_page).permit(:name, :text_body)
    end
end

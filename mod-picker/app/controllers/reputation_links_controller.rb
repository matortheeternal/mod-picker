class ReputationLinksController < ApplicationController
  before_action :set_reputation_link, only: [:show, :edit, :update, :destroy]

  # GET /reputation_links
  # GET /reputation_links.json
  def index
    @reputation_links = ReputationLink.all
  end

  # GET /reputation_links/1
  # GET /reputation_links/1.json
  def show
  end

  # GET /reputation_links/new
  def new
    @reputation_link = ReputationLink.new
  end

  # GET /reputation_links/1/edit
  def edit
  end

  # POST /reputation_links
  # POST /reputation_links.json
  def create
    @reputation_link = ReputationLink.new(reputation_link_params)

    respond_to do |format|
      if @reputation_link.save
        format.html { redirect_to @reputation_link, notice: 'Reputation map was successfully created.' }
        format.json { render :show, status: :created, location: @reputation_link }
      else
        format.html { render :new }
        format.json { render json: @reputation_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reputation_links/1
  # PATCH/PUT /reputation_links/1.json
  def update
    respond_to do |format|
      if @reputation_link.update(reputation_link_params)
        format.html { redirect_to @reputation_link, notice: 'Reputation map was successfully updated.' }
        format.json { render :show, status: :ok, location: @reputation_link }
      else
        format.html { render :edit }
        format.json { render json: @reputation_link.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reputation_links/1
  # DELETE /reputation_links/1.json
  def destroy
    @reputation_link.destroy
    respond_to do |format|
      format.html { redirect_to reputation_links_url, notice: 'Reputation map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reputation_link
      @reputation_link = ReputationLink.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reputation_link_params
      params.require(:reputation_link).permit(:from_rep_id, :to_rep_id)
    end
end

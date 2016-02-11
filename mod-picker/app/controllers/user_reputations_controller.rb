class UserReputationsController < ApplicationController
  before_action :set_user_reputation, only: [:show, :edit, :update, :destroy]

  # GET /user_reputations
  # GET /user_reputations.json
  def index
    @user_reputations = UserReputation.all

    respond_to do |format|
      format.html
      format.json { render :json => @user_reputations}
    end
  end

  # GET /user_reputations/1
  # GET /user_reputations/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @user_reputation}
    end
  end

  # GET /user_reputations/new
  def new
    @user_reputation = UserReputation.new
  end

  # GET /user_reputations/1/edit
  def edit
  end

  # POST /user_reputations
  # POST /user_reputations.json
  def create
    @user_reputation = UserReputation.new(user_reputation_params)

    respond_to do |format|
      if @user_reputation.save
        format.html { redirect_to @user_reputation, notice: 'User reputation was successfully created.' }
        format.json { render :show, status: :created, location: @user_reputation }
      else
        format.html { render :new }
        format.json { render json: @user_reputation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_reputations/1
  # PATCH/PUT /user_reputations/1.json
  def update
    respond_to do |format|
      if @user_reputation.update(user_reputation_params)
        format.html { redirect_to @user_reputation, notice: 'User reputation was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_reputation }
      else
        format.html { render :edit }
        format.json { render json: @user_reputation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_reputations/1
  # DELETE /user_reputations/1.json
  def destroy
    @user_reputation.destroy
    respond_to do |format|
      format.html { redirect_to user_reputations_url, notice: 'User reputation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_reputation
      @user_reputation = UserReputation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_reputation_params
      params.require(:user_reputation).permit(:user_id, :overall, :offset, :audiovisual_design, :plugin_design, :utility_design, :script_design)
    end
end

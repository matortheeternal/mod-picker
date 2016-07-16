class UsersController < ApplicationController
  before_action :set_user, only: [:show, :comments, :update, :destroy]

  # GET /users
  def index
    @users = User.includes(:reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count =  User.accessible_by(current_ability).filter(filtering_params).count

    render :json => {
        users: @users,
        max_entries: count,
        entries_per_page: User.per_page
    }
  end

  # GET /current_user
  def current
    render :json => current_user.current_json
  end

  # POST /users/search
  def search
    @users = User.filter(search_params).sort({ column: "username", direction: "ASC" }).limit(10)
    render :json => User.search_json(@users)
  end

  # GET /users/1
  def show
    authorize! :read, @user
    render :json => @user.show_json(current_user)
  end

  # GET /link_account
  def link_account
    bio = current_user.bio
    case params[:site]
      when "Nexus Mods"
        verified = bio.verify_nexus_account(params[:user_path])
      when "Lover's Lab"
        verified = bio.verify_lover_account(params[:user_path])
      when "Steam Workshop"
        verified = bio.verify_workshop_account(params[:user_path])
      else
        verified = false
    end

    if verified
      render json: {status: :ok, verified: true, bio: bio}
    else
      render json: {status: :ok, verified: false}
    end
  end

  # GET /users/1/comments
  def comments
    authorize! :read, @user
    comments = @user.profile_comments.accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
    count = @user.profile_comments.accessible_by(current_ability).count
    render :json => {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # PATCH/PUT /users/1
  def update
    authorize! :update, @user
    if @user.update(user_params)
      render json: {status: :ok}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    authorize! :destroy, @user
    if @user.destroy
      render json: {status: :ok}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.joins(:bio, :reputation).find(params[:id])
    end

    def search_params
      params[:filters].slice(:search)
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:search, :linked, :roles, :reputation, :joined, :last_seen, :authored_mods, :mod_lists, :comments, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, :corrections)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :role, :title, :joined, :active_mod_list_id, :email, :about_me)
    end
end

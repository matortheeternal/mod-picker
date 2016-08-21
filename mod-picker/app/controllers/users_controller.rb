class UsersController < ApplicationController
  before_action :set_user, only: [:show, :comments, :endorse, :unendorse]

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
    endorsed = ReputationLink.exists?(from_rep_id: current_user.reputation.id, to_rep_id: @user.reputation.id)
    render :json => {
        user: @user.show_json(current_user),
        endorsed: endorsed
    }
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

  # POST /users/1/rep
  def endorse
    @reputation_link = ReputationLink.find_or_initialize_by(from_rep_id: current_user.reputation.id, to_rep_id: @user.reputation.id)
    authorize! :create, @reputation_link
    if @reputation_link.save
      render json: {status: :ok}
    else
      render json: @reputation_link.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1/rep
  def unendorse
    @reputation_link = ReputationLink.find_by(from_rep_id: current_user.reputation.id, to_rep_id: @user.reputation.id)
    if @reputation_link.nil?
      render json: {status: :ok}
    else
      authorize! :destroy, @reputation_link
      if @reputation_link.destroy
        render json: {status: :ok}
      else
        render json: @reputation_link.errors, status: :unprocessable_entity
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def search_params
      params[:filters].slice(:search)
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:search, :linked, :roles, :reputation, :joined, :last_seen, :authored_mods, :mod_lists, :comments, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, :corrections)
    end
end

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :comments, :endorse, :unendorse, :add_rep, :subtract_rep, :change_role, :mod_lists, :mods]

  # GET/POST /users/index
  def index
    @users = User.include_blank(false).includes(:reputation).references(:reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count =  User.include_blank(false).includes(:reputation).references(:reputation).accessible_by(current_ability).filter(filtering_params).count

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

  # POST /users/1/add_rep
  def add_rep
    authorize! :adjust_rep, @user
    if @user.reputation.add_offset
      render json: {status: :ok}
    else
      render json: @user.reputation.errors, status: :unprocessable_entity
    end
  end

  # POST /users/1/subtract_rep
  def subtract_rep
    authorize! :adjust_rep, @user
    if @user.reputation.subtract_offset
      render json: {status: :ok}
    else
      render json: @user.reputation.errors, status: :unprocessable_entity
    end
  end

  # POST /users/1/change_role
  def change_role
    authorize! :assign_roles, @user
    if params[:role] == "admin" && !current_user.admin?
      raise "Only admins can make other users admins."
    end
    if @user.admin?
      raise "You cannot change the role of admin users."
    end

    if @user.update(role: params[:role])
      render json: {status: :ok}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET /users/1/mod_lists
  def mod_lists
    authorize! :read, @user

    favorite_mod_lists = @user.starred_mod_lists.accessible_by(current_ability)
    authored_mod_lists = @user.mod_lists.accessible_by(current_ability)

    render :json => {
      favorites: favorite_mod_lists,
      authored: authored_mod_lists
    }
  end

  # GET /users/1/mods
  def mods
    authorize! :read, @user

    favorite_mods = @user.starred_mods.includes(:author_users).accessible_by(current_ability)
    authored_mods = @user.mods.includes(:author_users).accessible_by(current_ability)
    sources = { :nexus => true, :lab => true, :workshop => true }

    render :json => {
        favorites: Mod.index_json(favorite_mods, sources),
        authored: Mod.index_json(authored_mods, sources)
    }
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
      params[:filters].slice(:search, :linked, :roles, :reputation, :joined, :last_seen, :authored_mods, :mod_lists, :submitted_comments, :comments, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, :corrections)
    end
end

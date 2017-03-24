class Api::V1::UsersController < Api::ApiController
  before_action :set_user, only: [:show, :comments, :mod_lists, :mods]

  # GET/POST /users/index
  def index
    @users = User.include_blank(false).includes(:reputation).references(:reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count =  User.include_blank(false).includes(:reputation).references(:reputation).accessible_by(current_ability).filter(filtering_params).count

    render json: {
        users: json_format(@users),
        max_entries: count,
        entries_per_page: User.per_page
    }
  end

  # POST /users/search
  def search
    @users = User.filter(search_params).sort({ column: "username", direction: "ASC" }).limit(10)
    respond_with_json(@users)
  end

  # GET /users/1
  def show
    authorize! :read, @user
    respond_with_json(@user, :show, :user)
  end

  # GET /users/1/comments
  def comments
    authorize! :read, @user
    comments = @user.profile_comments.includes(submitter: :reputation, children: [submitter: :reputation]).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count = @user.profile_comments.accessible_by(current_ability).count

    render json: {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # GET /users/1/mods
  def mods
    authorize! :read, @user

    favorite_mods = @user.starred_mods.includes(:author_users).accessible_by(current_ability)
    authored_mods = @user.mods.includes(:author_users).accessible_by(current_ability)
    sources = { nexus: true, lab: true, workshop: true }

    render json: {
        favorites: json_format(favorite_mods, :index),
        authored: json_format(authored_mods, :index)
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def search_params
      if params[:filters].has_key?(:search)
        params[:filters][:search] = "username:#{params[:filters][:search]}"
      end
      params[:filters].slice(:search)
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:search, :roles, :reputation, :joined, :last_seen, :authored_mods, :mod_lists, :submitted_comments, :comments, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, :corrections)
    end
end

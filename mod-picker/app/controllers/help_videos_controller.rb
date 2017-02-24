class HelpVideosController < ApplicationController
  before_action :set_help_video, only: [:show, :edit]
  before_action :set_help_video_from_id, only: [:sections, :update, :destroy]
  rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found

  layout "help"

  # GET /videos/:title
  def show
    authorize! :read, @help_video
    render "help_videos/show"
  end

  # GET /videos/:title/edit
  def edit
    authorize! :update, @help_video
    render "help_videos/edit"
  end

  # GET /videos/new
  def new
    @help_video = HelpVideo.new
    authorize! :create, @help_video
    render "help_videos/new"
  end

  # POST /videos/new
  def create
    @help_video = HelpVideo.new(help_video_params)
    @help_video.submitted_by = current_user.id
    authorize! :create, @help_video

    if @help_video.save
      redirect_to "/videos/#{@help_video.url}"
    else
      render "help_videos/new"
    end
  end

  # GET /videos/1/sections
  def sections
    authorize! :read, @help_video
    sections = @help_video.sections.includes(:children)
    render json: {
        sections: sections,
    }
  end

  # PATCH/PUT /videos/1
  def update
    authorize! :update, @help_video
    authorize! :approve, @help_video, :message => "You are not allowed to approve/unapprove this help video." if params[:help_video].has_key?(:approved)
    if @help_video.update(help_video_params)
      redirect_to "/videos/#{@help_video.url}"
    else
      render "help_videos/edit"
    end
  end

  # DELETE /videos/1
  def destroy
    authorize! :destroy, @help_video

    if @help_video.destroy
      redirect_to action: "index"
    else
      redirect_to "/videos/#{@help_video.url}/edit"
    end
  end

  private
    # set instance variable via /videos/:id via callback to keep things DRY
    def set_help_video
      @help_video = HelpVideo.find_by(title: params[:id].humanize)
      raise ActiveRecord::RecordNotFound if @help_video.nil?
    end

    def set_help_video_from_id
      @help_video = HelpVideo.find(params[:id])
    end

    def help_video_params
      params.require(:help_video).permit(:game_id, :approved, :category, :youtube_id, :title, :text_body, sections_attributes: [:id, :label, :description, :seconds, :_destroy])
    end
end

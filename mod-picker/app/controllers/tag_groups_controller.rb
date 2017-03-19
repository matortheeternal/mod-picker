class TagGroupsController < ApplicationController
  # GET /tag_groups
  def index
    @tag_groups = TagGroup.game(params[:game]).category(params[:category]).includes(:tag_group_tags => :tag)
    respond_with_json(@tag_groups)
  end
end

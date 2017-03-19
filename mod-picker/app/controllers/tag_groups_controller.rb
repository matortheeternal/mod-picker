class TagGroupsController < ApplicationController
  # GET /tag_groups
  def index
    @tag_groups = TagGroup.category(params[:category])
    respond_with_json(@tag_groups)
  end
end

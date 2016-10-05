class ModListGroupsController < ApplicationController
  # POST /mod_list_groups
  # Creates a new mod list group and renders it as JSON
  def create
    @mod_list_group = ModListGroup.new(mod_list_group_params)
    authorize! :update, @mod_list_group.mod_list

    if @mod_list_group.save
      render json: @mod_list_group
    else
      render json: @mod_list_group.errors, status: :unprocessable_entity
    end
  end

  private
    def mod_list_group_params
      params.require(:mod_list_group).permit(:mod_list_id, :index, :tab, :color, :name, :description)
    end
end

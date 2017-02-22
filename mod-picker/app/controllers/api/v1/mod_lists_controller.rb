class Api::V1::ModListsController < Api::ApiController
  before_action :set_mod_list, only: [:step]

  # GET /mod_list/1/step
  def step
    @mod_list = ModList.find(params[:id])

    groups = @mod_list.mod_list_groups.where(tab: [0, 1]).order(:index)
    mods = @mod_list.mod_list_mods.eager_load(:mod).where(mods: {is_official: false}).order(:index).preload({:mod => [:lover_infos, :workshop_infos, :custom_sources, :tags, {:nexus_infos => :game}, {:required_mods => :required_mod}]}, {:mod_list_mod_options => :mod_option})
    custom_mods = @mod_list.custom_mods

    render json: {
        groups: ModListGroup.nested_json(groups, mods, custom_mods)
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list
      @mod_list = ModList.find(params[:id])
    end
end

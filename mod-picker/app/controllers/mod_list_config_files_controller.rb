class ModListConfigFilesController < ApplicationController
  def create
    @mod_list_config_file = ModListConfigFile.new(mod_list_config_file_params)
    authorize! :update, @mod_list_config_file.mod_list

    if @mod_list_config_file.save
      render json: {
          mod_list_config_file: @mod_list_config_file
      }
    else
      render json: @mod_list_config_file.errors, status: :unprocessable_entity
    end
  end

  private
    def mod_list_config_file_params
      params.require(:mod_list_config_file).permit(:mod_list_id, :config_file_id)
    end
end

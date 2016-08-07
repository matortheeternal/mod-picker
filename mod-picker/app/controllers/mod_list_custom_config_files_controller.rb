class ModListCustomConfigFilesController < ApplicationController

  def create
    @mod_list_custom_config_file = ModListCustomConfigFile.new(mod_list_custom_config_file_params)

    if @mod_list_custom_config_file.save
      # render response
      render json: {
          mod_list_custom_config_file: @mod_list_custom_config_file
      }
    else
      render json: @mod_list_custom_config_file.errors, status: :unprocessable_entity
    end
  end

  private
    def mod_list_custom_config_file_params
      params.require(:mod_list_custom_config_file).permit(:mod_list_id, :filename, :install_path, :text_body)
    end
end

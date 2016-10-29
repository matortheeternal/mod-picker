class ModListModsController < ApplicationController
  # POST /mod_list_mods
  def create
    @mod_list_mod = ModListMod.new(mod_list_mod_params)
    authorize! :read, @mod_list_mod.mod
    authorize! :update, @mod_list_mod.mod_list

    if @mod_list_mod.save
      if params[:no_response]
        render json: {status: :ok}
      else
        # prepare notes
        mod_compatibility_notes = @mod_list_mod.mod_compatibility_notes
        plugin_compatibility_notes = @mod_list_mod.plugin_compatibility_notes
        install_order_notes = @mod_list_mod.install_order_notes
        load_order_notes = @mod_list_mod.load_order_notes

        # prepare helpful marks
        c_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("CompatibilityNote", mod_compatibility_notes.ids + plugin_compatibility_notes.ids)
        i_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("InstallOrderNote", install_order_notes.ids)
        l_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("LoadOrderNote", load_order_notes.ids)

        # render response
        # TODO: Don't render current plugins if the plugins tab isn't loaded
        render json: {
            mod_list_mod: @mod_list_mod,
            mod_list_plugins: @mod_list_mod.current_plugins,
            required_tools: @mod_list_mod.required_tools,
            required_mods: @mod_list_mod.required_mods,
            mod_compatibility_notes: mod_compatibility_notes,
            plugin_compatibility_notes: plugin_compatibility_notes,
            install_order_notes: install_order_notes,
            load_order_notes: load_order_notes,
            c_helpful_marks: c_helpful_marks,
            i_helpful_marks: i_helpful_marks,
            l_helpful_marks: l_helpful_marks
        }
      end
    else
      render json: @mod_list_mod.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mod_list_mods
  def destroy
    @mod_list_mod = ModListMod.find_by(mod_list_id: params[:mod_list_id], mod_id: params[:mod_id])
    authorize! :update, @mod_list_mod.mod_list

    if @mod_list_mod.destroy
      render json: {status: :ok}
    else
      render json: @mod_list_mod.errors, status: :unprocessable_entity
    end
  end

  private
    def mod_list_mod_params
      params.require(:mod_list_mod).permit(:mod_list_id, :mod_id, :index)
    end
end

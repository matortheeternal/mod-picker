class RecordGroupsController < ApplicationController
  # GET /plugin_record_groups
  # GET /plugin_record_groups.json
  def index
    @plugin_record_groups = PluginRecordGroup.all

    render :json => @plugin_record_groups
  end
end

require 'test_helper'

class PluginRecordGroupsControllerTest < ActionController::TestCase
  setup do
    @plugin_record_group = plugin_record_groups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plugin_record_groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plugin_record_group" do
    assert_difference('PluginRecordGroup.count') do
      post :create, plugin_record_group: { name: @plugin_record_group.name, new_records: @plugin_record_group.new_records, override_records: @plugin_record_group.override_records, pl_id: @plugin_record_group.pl_id, sig: @plugin_record_group.sig }
    end

    assert_redirected_to plugin_record_group_path(assigns(:plugin_record_group))
  end

  test "should show plugin_record_group" do
    get :show, id: @plugin_record_group
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plugin_record_group
    assert_response :success
  end

  test "should update plugin_record_group" do
    patch :update, id: @plugin_record_group, plugin_record_group: { name: @plugin_record_group.name, new_records: @plugin_record_group.new_records, override_records: @plugin_record_group.override_records, pl_id: @plugin_record_group.pl_id, sig: @plugin_record_group.sig }
    assert_redirected_to plugin_record_group_path(assigns(:plugin_record_group))
  end

  test "should destroy plugin_record_group" do
    assert_difference('PluginRecordGroup.count', -1) do
      delete :destroy, id: @plugin_record_group
    end

    assert_redirected_to plugin_record_groups_path
  end
end

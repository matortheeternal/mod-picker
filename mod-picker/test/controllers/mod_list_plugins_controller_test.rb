require 'test_helper'

class ModListPluginsControllerTest < ActionController::TestCase
  setup do
    @mod_list_plugin = mod_list_plugins(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_list_plugins)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_list_plugin" do
    assert_difference('ModListPlugin.count') do
      post :create, mod_list_plugin: { active: @mod_list_plugin.active, load_order: @mod_list_plugin.load_order, mod_list_id: @mod_list_plugin.mod_list_id, plugin_id: @mod_list_plugin.plugin_id }
    end

    assert_redirected_to mod_list_plugin_path(assigns(:mod_list_plugin))
  end

  test "should show mod_list_plugin" do
    get :show, id: @mod_list_plugin
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_list_plugin
    assert_response :success
  end

  test "should update mod_list_plugin" do
    patch :update, id: @mod_list_plugin, mod_list_plugin: { active: @mod_list_plugin.active, load_order: @mod_list_plugin.load_order, mod_list_id: @mod_list_plugin.mod_list_id, plugin_id: @mod_list_plugin.plugin_id }
    assert_redirected_to mod_list_plugin_path(assigns(:mod_list_plugin))
  end

  test "should destroy mod_list_plugin" do
    assert_difference('ModListPlugin.count', -1) do
      delete :destroy, id: @mod_list_plugin
    end

    assert_redirected_to mod_list_plugins_path
  end
end

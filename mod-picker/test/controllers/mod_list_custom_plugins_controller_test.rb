require 'test_helper'

class ModListCustomPluginsControllerTest < ActionController::TestCase
  setup do
    @mod_list_custom_plugin = mod_list_custom_plugins(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_list_custom_plugins)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_list_custom_plugin" do
    assert_difference('ModListCustomPlugin.count') do
      post :create, mod_list_custom_plugin: { active: @mod_list_custom_plugin.active, description: @mod_list_custom_plugin.description, load_order: @mod_list_custom_plugin.load_order, ml_id: @mod_list_custom_plugin.ml_id, title: @mod_list_custom_plugin.title }
    end

    assert_redirected_to mod_list_custom_plugin_path(assigns(:mod_list_custom_plugin))
  end

  test "should show mod_list_custom_plugin" do
    get :show, id: @mod_list_custom_plugin
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_list_custom_plugin
    assert_response :success
  end

  test "should update mod_list_custom_plugin" do
    patch :update, id: @mod_list_custom_plugin, mod_list_custom_plugin: { active: @mod_list_custom_plugin.active, description: @mod_list_custom_plugin.description, load_order: @mod_list_custom_plugin.load_order, ml_id: @mod_list_custom_plugin.ml_id, title: @mod_list_custom_plugin.title }
    assert_redirected_to mod_list_custom_plugin_path(assigns(:mod_list_custom_plugin))
  end

  test "should destroy mod_list_custom_plugin" do
    assert_difference('ModListCustomPlugin.count', -1) do
      delete :destroy, id: @mod_list_custom_plugin
    end

    assert_redirected_to mod_list_custom_plugins_path
  end
end

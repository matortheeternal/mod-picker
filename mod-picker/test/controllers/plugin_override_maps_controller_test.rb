require 'test_helper'

class PluginOverrideMapsControllerTest < ActionController::TestCase
  setup do
    @plugin_override_map = plugin_override_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plugin_overrides)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plugin_override_map" do
    assert_difference('PluginOverride.count') do
      post :create, plugin_override_map: { form_id: @plugin_override_map.form_id, master_id: @plugin_override_map.master_id, plugin_id: @plugin_override_map.plugin_id }
    end

    assert_redirected_to plugin_override_map_path(assigns(:plugin_override_map))
  end

  test "should show plugin_override_map" do
    get :show, id: @plugin_override_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plugin_override_map
    assert_response :success
  end

  test "should update plugin_override_map" do
    patch :update, id: @plugin_override_map, plugin_override_map: { form_id: @plugin_override_map.form_id, master_id: @plugin_override_map.master_id, plugin_id: @plugin_override_map.plugin_id }
    assert_redirected_to plugin_override_map_path(assigns(:plugin_override_map))
  end

  test "should destroy plugin_override_map" do
    assert_difference('PluginOverride.count', -1) do
      delete :destroy, id: @plugin_override_map
    end

    assert_redirected_to plugin_override_maps_path
  end
end

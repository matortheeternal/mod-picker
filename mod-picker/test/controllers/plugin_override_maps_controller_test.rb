require 'test_helper'

class PluginOverrideMapsControllerTest < ActionController::TestCase
  setup do
    @plugin_override_map = plugin_override_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:plugin_override_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create plugin_override_map" do
    assert_difference('PluginOverrideMap.count') do
      post :create, plugin_override_map: { form_id: @plugin_override_map.form_id, mst_id: @plugin_override_map.mst_id, pl_id: @plugin_override_map.pl_id }
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
    patch :update, id: @plugin_override_map, plugin_override_map: { form_id: @plugin_override_map.form_id, mst_id: @plugin_override_map.mst_id, pl_id: @plugin_override_map.pl_id }
    assert_redirected_to plugin_override_map_path(assigns(:plugin_override_map))
  end

  test "should destroy plugin_override_map" do
    assert_difference('PluginOverrideMap.count', -1) do
      delete :destroy, id: @plugin_override_map
    end

    assert_redirected_to plugin_override_maps_path
  end
end

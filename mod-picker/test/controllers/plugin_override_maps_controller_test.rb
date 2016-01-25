require 'test_helper'

class PluginOverrideMapsControllerTest < ActionController::TestCase
  setup do
    @plugin_override = plugin_overrides(:one)
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

  test "should create plugin_override" do
    assert_difference('PluginOverride.count') do
      post :create, plugin_override: { form_id: @plugin_override.form_id, master_id: @plugin_override.master_id, plugin_id: @plugin_override.plugin_id }
    end

    assert_redirected_to plugin_override_path(assigns(:plugin_override))
  end

  test "should show plugin_override" do
    get :show, id: @plugin_override
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @plugin_override
    assert_response :success
  end

  test "should update plugin_override" do
    patch :update, id: @plugin_override, plugin_override: { form_id: @plugin_override.form_id, master_id: @plugin_override.master_id, plugin_id: @plugin_override.plugin_id }
    assert_redirected_to plugin_override_path(assigns(:plugin_override))
  end

  test "should destroy plugin_override" do
    assert_difference('PluginOverride.count', -1) do
      delete :destroy, id: @plugin_override
    end

    assert_redirected_to plugin_overrides_path
  end
end

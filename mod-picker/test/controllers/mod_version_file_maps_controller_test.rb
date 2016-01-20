require 'test_helper'

class ModVersionFileMapsControllerTest < ActionController::TestCase
  setup do
    @mod_version_file_map = mod_version_file_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_version_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_version_file_map" do
    assert_difference('ModVersionFile.count') do
      post :create, mod_version_file_map: { mod_asset_file_id: @mod_version_file_map.mod_asset_file_id, mod_version_id: @mod_version_file_map.mod_version_id }
    end

    assert_redirected_to mod_version_file_map_path(assigns(:mod_version_file_map))
  end

  test "should show mod_version_file_map" do
    get :show, id: @mod_version_file_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_version_file_map
    assert_response :success
  end

  test "should update mod_version_file_map" do
    patch :update, id: @mod_version_file_map, mod_version_file_map: { mod_asset_file_id: @mod_version_file_map.mod_asset_file_id, mod_version_id: @mod_version_file_map.mod_version_id }
    assert_redirected_to mod_version_file_map_path(assigns(:mod_version_file_map))
  end

  test "should destroy mod_version_file_map" do
    assert_difference('ModVersionFile.count', -1) do
      delete :destroy, id: @mod_version_file_map
    end

    assert_redirected_to mod_version_file_maps_path
  end
end

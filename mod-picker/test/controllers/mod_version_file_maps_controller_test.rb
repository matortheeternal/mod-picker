require 'test_helper'

class ModVersionFileMapsControllerTest < ActionController::TestCase
  setup do
    @mod_version_file = mod_version_files(:one)
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

  test "should create mod_version_file" do
    assert_difference('ModVersionFile.count') do
      post :create, mod_version_file: { mod_asset_file_id: @mod_version_file.mod_asset_file_id, mod_version_id: @mod_version_file.mod_version_id }
    end

    assert_redirected_to mod_version_file_path(assigns(:mod_version_file))
  end

  test "should show mod_version_file" do
    get :show, id: @mod_version_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_version_file
    assert_response :success
  end

  test "should update mod_version_file" do
    patch :update, id: @mod_version_file, mod_version_file: { mod_asset_file_id: @mod_version_file.mod_asset_file_id, mod_version_id: @mod_version_file.mod_version_id }
    assert_redirected_to mod_version_file_path(assigns(:mod_version_file))
  end

  test "should destroy mod_version_file" do
    assert_difference('ModVersionFile.count', -1) do
      delete :destroy, id: @mod_version_file
    end

    assert_redirected_to mod_version_files_path
  end
end

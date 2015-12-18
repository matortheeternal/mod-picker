require 'test_helper'

class ModAssetFilesControllerTest < ActionController::TestCase
  setup do
    @mod_asset_file = mod_asset_files(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_asset_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_asset_file" do
    assert_difference('ModAssetFile.count') do
      post :create, mod_asset_file: { filepath: @mod_asset_file.filepath, maf_id: @mod_asset_file.maf_id }
    end

    assert_redirected_to mod_asset_file_path(assigns(:mod_asset_file))
  end

  test "should show mod_asset_file" do
    get :show, id: @mod_asset_file
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_asset_file
    assert_response :success
  end

  test "should update mod_asset_file" do
    patch :update, id: @mod_asset_file, mod_asset_file: { filepath: @mod_asset_file.filepath, maf_id: @mod_asset_file.maf_id }
    assert_redirected_to mod_asset_file_path(assigns(:mod_asset_file))
  end

  test "should destroy mod_asset_file" do
    assert_difference('ModAssetFile.count', -1) do
      delete :destroy, id: @mod_asset_file
    end

    assert_redirected_to mod_asset_files_path
  end
end

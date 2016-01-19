require 'test_helper'

class ModVersionsControllerTest < ActionController::TestCase
  setup do
    @mod_version = mod_versions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_versions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_version" do
    assert_difference('ModVersion.count') do
      post :create, mod_version: { dangerous: @mod_version.dangerous, mod_id: @mod_version.mod_id, mv_id: @mod_version.mv_id, nxm_file_id: @mod_version.nxm_file_id, obsolete: @mod_version.obsolete, released: @mod_version.released }
    end

    assert_redirected_to mod_version_path(assigns(:mod_version))
  end

  test "should show mod_version" do
    get :show, id: @mod_version
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_version
    assert_response :success
  end

  test "should update mod_version" do
    patch :update, id: @mod_version, mod_version: { dangerous: @mod_version.dangerous, mod_id: @mod_version.mod_id, mv_id: @mod_version.mv_id, nxm_file_id: @mod_version.nxm_file_id, obsolete: @mod_version.obsolete, released: @mod_version.released }
    assert_redirected_to mod_version_path(assigns(:mod_version))
  end

  test "should destroy mod_version" do
    assert_difference('ModVersion.count', -1) do
      delete :destroy, id: @mod_version
    end

    assert_redirected_to mod_versions_path
  end
end

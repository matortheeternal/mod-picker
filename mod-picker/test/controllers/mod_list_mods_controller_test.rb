require 'test_helper'

class ModListModsControllerTest < ActionController::TestCase
  setup do
    @mod_list_mod = mod_list_mods(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_list_mods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_list_mod" do
    assert_difference('ModListMod.count') do
      post :create, mod_list_mod: { active: @mod_list_mod.active, install_order: @mod_list_mod.install_order, mod_id: @mod_list_mod.mod_id, mod_list_id: @mod_list_mod.mod_list_id }
    end

    assert_redirected_to mod_list_mod_path(assigns(:mod_list_mod))
  end

  test "should show mod_list_mod" do
    get :show, id: @mod_list_mod
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_list_mod
    assert_response :success
  end

  test "should update mod_list_mod" do
    patch :update, id: @mod_list_mod, mod_list_mod: { active: @mod_list_mod.active, install_order: @mod_list_mod.install_order, mod_id: @mod_list_mod.mod_id, mod_list_id: @mod_list_mod.mod_list_id }
    assert_redirected_to mod_list_mod_path(assigns(:mod_list_mod))
  end

  test "should destroy mod_list_mod" do
    assert_difference('ModListMod.count', -1) do
      delete :destroy, id: @mod_list_mod
    end

    assert_redirected_to mod_list_mods_path
  end
end

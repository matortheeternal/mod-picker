require 'test_helper'

class ModsControllerTest < ActionController::TestCase
  setup do
    @mod = mods(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mods)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod" do
    assert_difference('Mod.count') do
      post :create, mod: { aliases: @mod.aliases, category: @mod.category, game: @mod.game, has_adult_content: @mod.has_adult_content, is_utility: @mod.is_utility, ll_id: @mod.ll_id, mod_id: @mod.mod_id, name: @mod.name, nm_id: @mod.nm_id, ws_id: @mod.ws_id }
    end

    assert_redirected_to mod_path(assigns(:mod))
  end

  test "should show mod" do
    get :show, id: @mod
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod
    assert_response :success
  end

  test "should update mod" do
    patch :update, id: @mod, mod: { aliases: @mod.aliases, category: @mod.category, game: @mod.game, has_adult_content: @mod.has_adult_content, is_utility: @mod.is_utility, ll_id: @mod.ll_id, mod_id: @mod.mod_id, name: @mod.name, nm_id: @mod.nm_id, ws_id: @mod.ws_id }
    assert_redirected_to mod_path(assigns(:mod))
  end

  test "should destroy mod" do
    assert_difference('Mod.count', -1) do
      delete :destroy, id: @mod
    end

    assert_redirected_to mods_path
  end
end

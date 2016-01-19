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
      post :create, mod: { aliases: @mod.aliases, game_id: @mod.game_id, has_adult_content: @mod.has_adult_content, is_utility: @mod.is_utility, mod_id: @mod.mod_id, name: @mod.name, primary_category_id: @mod.primary_category_id, secondary_category_id: @mod.secondary_category_id }
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
    patch :update, id: @mod, mod: { aliases: @mod.aliases, game_id: @mod.game_id, has_adult_content: @mod.has_adult_content, is_utility: @mod.is_utility, mod_id: @mod.mod_id, name: @mod.name, primary_category_id: @mod.primary_category_id, secondary_category_id: @mod.secondary_category_id }
    assert_redirected_to mod_path(assigns(:mod))
  end

  test "should destroy mod" do
    assert_difference('Mod.count', -1) do
      delete :destroy, id: @mod
    end

    assert_redirected_to mods_path
  end
end

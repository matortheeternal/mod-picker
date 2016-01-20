require 'test_helper'

class UserModListStarMapsControllerTest < ActionController::TestCase
  setup do
    @user_mod_list_star_map = user_mod_list_star_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_list_stars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_mod_list_star_map" do
    assert_difference('ModListStar.count') do
      post :create, user_mod_list_star_map: { mod_list_id: @user_mod_list_star_map.mod_list_id, user_id: @user_mod_list_star_map.user_id }
    end

    assert_redirected_to user_mod_list_star_map_path(assigns(:user_mod_list_star_map))
  end

  test "should show user_mod_list_star_map" do
    get :show, id: @user_mod_list_star_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_mod_list_star_map
    assert_response :success
  end

  test "should update user_mod_list_star_map" do
    patch :update, id: @user_mod_list_star_map, user_mod_list_star_map: { mod_list_id: @user_mod_list_star_map.mod_list_id, user_id: @user_mod_list_star_map.user_id }
    assert_redirected_to user_mod_list_star_map_path(assigns(:user_mod_list_star_map))
  end

  test "should destroy user_mod_list_star_map" do
    assert_difference('ModListStar.count', -1) do
      delete :destroy, id: @user_mod_list_star_map
    end

    assert_redirected_to user_mod_list_star_maps_path
  end
end

require 'test_helper'

class UserModAuthorMapsControllerTest < ActionController::TestCase
  setup do
    @user_mod_author_map = user_mod_author_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_mod_author_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_mod_author_map" do
    assert_difference('UserModAuthorMap.count') do
      post :create, user_mod_author_map: { mod_id: @user_mod_author_map.mod_id, user_id: @user_mod_author_map.user_id }
    end

    assert_redirected_to user_mod_author_map_path(assigns(:user_mod_author_map))
  end

  test "should show user_mod_author_map" do
    get :show, id: @user_mod_author_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_mod_author_map
    assert_response :success
  end

  test "should update user_mod_author_map" do
    patch :update, id: @user_mod_author_map, user_mod_author_map: { mod_id: @user_mod_author_map.mod_id, user_id: @user_mod_author_map.user_id }
    assert_redirected_to user_mod_author_map_path(assigns(:user_mod_author_map))
  end

  test "should destroy user_mod_author_map" do
    assert_difference('UserModAuthorMap.count', -1) do
      delete :destroy, id: @user_mod_author_map
    end

    assert_redirected_to user_mod_author_maps_path
  end
end

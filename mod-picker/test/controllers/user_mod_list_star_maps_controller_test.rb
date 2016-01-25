require 'test_helper'

class UserModListStarMapsControllerTest < ActionController::TestCase
  setup do
    @mod_list_star = mod_list_stars(:one)
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

  test "should create mod_list_star" do
    assert_difference('ModListStar.count') do
      post :create, mod_list_star: { mod_list_id: @mod_list_star.mod_list_id, user_id: @mod_list_star.user_id }
    end

    assert_redirected_to mod_list_star_path(assigns(:mod_list_star))
  end

  test "should show mod_list_star" do
    get :show, id: @mod_list_star
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_list_star
    assert_response :success
  end

  test "should update mod_list_star" do
    patch :update, id: @mod_list_star, mod_list_star: { mod_list_id: @mod_list_star.mod_list_id, user_id: @mod_list_star.user_id }
    assert_redirected_to mod_list_star_path(assigns(:mod_list_star))
  end

  test "should destroy mod_list_star" do
    assert_difference('ModListStar.count', -1) do
      delete :destroy, id: @mod_list_star
    end

    assert_redirected_to mod_list_stars_path
  end
end

require 'test_helper'

class UserModStarMapsControllerTest < ActionController::TestCase
  setup do
    @mod_star = mod_stars(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_stars)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_star" do
    assert_difference('ModStar.count') do
      post :create, mod_star: { mod_id: @mod_star.mod_id, user_id: @mod_star.user_id }
    end

    assert_redirected_to mod_star_path(assigns(:mod_star))
  end

  test "should show mod_star" do
    get :show, id: @mod_star
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_star
    assert_response :success
  end

  test "should update mod_star" do
    patch :update, id: @mod_star, mod_star: { mod_id: @mod_star.mod_id, user_id: @mod_star.user_id }
    assert_redirected_to mod_star_path(assigns(:mod_star))
  end

  test "should destroy mod_star" do
    assert_difference('ModStar.count', -1) do
      delete :destroy, id: @mod_star
    end

    assert_redirected_to mod_stars_path
  end
end

require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { active_mc_id: @user.active_mc_id, active_ml_id: @user.active_ml_id, avatar: @user.avatar, bio_id: @user.bio_id, email: @user.email, hash: @user.hash, joined: @user.joined, last_seen: @user.last_seen, rep_id: @user.rep_id, set_id: @user.set_id, title: @user.title, user_id: @user.user_id, user_level: @user.user_level, username: @user.username }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    patch :update, id: @user, user: { active_mc_id: @user.active_mc_id, active_ml_id: @user.active_ml_id, avatar: @user.avatar, bio_id: @user.bio_id, email: @user.email, hash: @user.hash, joined: @user.joined, last_seen: @user.last_seen, rep_id: @user.rep_id, set_id: @user.set_id, title: @user.title, user_id: @user.user_id, user_level: @user.user_level, username: @user.username }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end

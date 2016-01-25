require 'test_helper'

class UserBiosControllerTest < ActionController::TestCase
  setup do
    @user_bio = user_bios(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_bios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_bio" do
    assert_difference('UserBio.count') do
      post :create, user_bio: { id: @user_bio.id, lover_username: @user_bio.lover_username, lover_verified: @user_bio.lover_verified, nexus_username: @user_bio.nexus_username, nexus_verified: @user_bio.nexus_verified, steam_username: @user_bio.steam_username, steam_verified: @user_bio.steam_verified, user_id: @user_bio.user_id }
    end

    assert_redirected_to user_bio_path(assigns(:user_bio))
  end

  test "should show user_bio" do
    get :show, id: @user_bio
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_bio
    assert_response :success
  end

  test "should update user_bio" do
    patch :update, id: @user_bio, user_bio: { id: @user_bio.id, lover_username: @user_bio.lover_username, lover_verified: @user_bio.lover_verified, nexus_username: @user_bio.nexus_username, nexus_verified: @user_bio.nexus_verified, steam_username: @user_bio.steam_username, steam_verified: @user_bio.steam_verified, user_id: @user_bio.user_id }
    assert_redirected_to user_bio_path(assigns(:user_bio))
  end

  test "should destroy user_bio" do
    assert_difference('UserBio.count', -1) do
      delete :destroy, id: @user_bio
    end

    assert_redirected_to user_bios_path
  end
end

require 'test_helper'

class UserCommentsControllerTest < ActionController::TestCase
  setup do
    @user_comment = user_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_comment" do
    assert_difference('UserComment.count') do
      post :create, user_comment: { comment_id: @user_comment.comment_id, user_id: @user_comment.user_id }
    end

    assert_redirected_to user_comment_path(assigns(:user_comment))
  end

  test "should show user_comment" do
    get :show, id: @user_comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_comment
    assert_response :success
  end

  test "should update user_comment" do
    patch :update, id: @user_comment, user_comment: { comment_id: @user_comment.comment_id, user_id: @user_comment.user_id }
    assert_redirected_to user_comment_path(assigns(:user_comment))
  end

  test "should destroy user_comment" do
    assert_difference('UserComment.count', -1) do
      delete :destroy, id: @user_comment
    end

    assert_redirected_to user_comments_path
  end
end

require 'test_helper'

class ModCommentsControllerTest < ActionController::TestCase
  setup do
    @mod_comment = mod_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_comment" do
    assert_difference('ModComment.count') do
      post :create, mod_comment: { comment_id: @mod_comment.comment_id, mod_id: @mod_comment.mod_id }
    end

    assert_redirected_to mod_comment_path(assigns(:mod_comment))
  end

  test "should show mod_comment" do
    get :show, id: @mod_comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_comment
    assert_response :success
  end

  test "should update mod_comment" do
    patch :update, id: @mod_comment, mod_comment: { comment_id: @mod_comment.comment_id, mod_id: @mod_comment.mod_id }
    assert_redirected_to mod_comment_path(assigns(:mod_comment))
  end

  test "should destroy mod_comment" do
    assert_difference('ModComment.count', -1) do
      delete :destroy, id: @mod_comment
    end

    assert_redirected_to mod_comments_path
  end
end

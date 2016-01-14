require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    @comment = comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create comment" do
    assert_difference('Comment.count') do
      post :create, comment: { c_id: @comment.c_id, edited: @comment.edited, hidden: @comment.hidden, parent_comment: @comment.parent_comment, submitted: @comment.submitted, submitted_by: @comment.submitted_by, text_body: @comment.text_body }
    end

    assert_redirected_to comment_path(assigns(:comment))
  end

  test "should show comment" do
    get :show, id: @comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @comment
    assert_response :success
  end

  test "should update comment" do
    patch :update, id: @comment, comment: { c_id: @comment.c_id, edited: @comment.edited, hidden: @comment.hidden, parent_comment: @comment.parent_comment, submitted: @comment.submitted, submitted_by: @comment.submitted_by, text_body: @comment.text_body }
    assert_redirected_to comment_path(assigns(:comment))
  end

  test "should destroy comment" do
    assert_difference('Comment.count', -1) do
      delete :destroy, id: @comment
    end

    assert_redirected_to comments_path
  end
end

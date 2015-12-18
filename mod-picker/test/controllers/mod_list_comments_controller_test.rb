require 'test_helper'

class ModListCommentsControllerTest < ActionController::TestCase
  setup do
    @mod_list_comment = mod_list_comments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_list_comments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_list_comment" do
    assert_difference('ModListComment.count') do
      post :create, mod_list_comment: { c_id: @mod_list_comment.c_id, ml_id: @mod_list_comment.ml_id }
    end

    assert_redirected_to mod_list_comment_path(assigns(:mod_list_comment))
  end

  test "should show mod_list_comment" do
    get :show, id: @mod_list_comment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_list_comment
    assert_response :success
  end

  test "should update mod_list_comment" do
    patch :update, id: @mod_list_comment, mod_list_comment: { c_id: @mod_list_comment.c_id, ml_id: @mod_list_comment.ml_id }
    assert_redirected_to mod_list_comment_path(assigns(:mod_list_comment))
  end

  test "should destroy mod_list_comment" do
    assert_difference('ModListComment.count', -1) do
      delete :destroy, id: @mod_list_comment
    end

    assert_redirected_to mod_list_comments_path
  end
end

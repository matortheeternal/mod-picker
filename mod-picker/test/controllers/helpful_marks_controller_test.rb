require 'test_helper'

class HelpfulMarksControllerTest < ActionController::TestCase
  setup do
    @helpful_mark = helpful_marks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:helpful_marks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create helpful_mark" do
    assert_difference('HelpfulMark.count') do
      post :create, helpful_mark: { cn_id: @helpful_mark.cn_id, helpful: @helpful_mark.helpful, in_id: @helpful_mark.in_id, r_id: @helpful_mark.r_id, submitted_by: @helpful_mark.submitted_by }
    end

    assert_redirected_to helpful_mark_path(assigns(:helpful_mark))
  end

  test "should show helpful_mark" do
    get :show, id: @helpful_mark
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @helpful_mark
    assert_response :success
  end

  test "should update helpful_mark" do
    patch :update, id: @helpful_mark, helpful_mark: { cn_id: @helpful_mark.cn_id, helpful: @helpful_mark.helpful, in_id: @helpful_mark.in_id, r_id: @helpful_mark.r_id, submitted_by: @helpful_mark.submitted_by }
    assert_redirected_to helpful_mark_path(assigns(:helpful_mark))
  end

  test "should destroy helpful_mark" do
    assert_difference('HelpfulMark.count', -1) do
      delete :destroy, id: @helpful_mark
    end

    assert_redirected_to helpful_marks_path
  end
end

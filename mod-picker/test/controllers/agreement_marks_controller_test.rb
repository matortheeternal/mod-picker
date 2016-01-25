require 'test_helper'

class AgreementMarksControllerTest < ActionController::TestCase
  setup do
    @agreement_mark = agreement_marks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:agreement_marks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create agreement_mark" do
    assert_difference('AgreementMark.count') do
      post :create, agreement_mark: { agree: @agreement_mark.agree, incorrect_note_id: @agreement_mark.incorrect_note_id, submitted_by: @agreement_mark.submitted_by }
    end

    assert_redirected_to agreement_mark_path(assigns(:agreement_mark))
  end

  test "should show agreement_mark" do
    get :show, id: @agreement_mark
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @agreement_mark
    assert_response :success
  end

  test "should update agreement_mark" do
    patch :update, id: @agreement_mark, agreement_mark: { agree: @agreement_mark.agree, incorrect_note_id: @agreement_mark.incorrect_note_id, submitted_by: @agreement_mark.submitted_by }
    assert_redirected_to agreement_mark_path(assigns(:agreement_mark))
  end

  test "should destroy agreement_mark" do
    assert_difference('AgreementMark.count', -1) do
      delete :destroy, id: @agreement_mark
    end

    assert_redirected_to agreement_marks_path
  end
end

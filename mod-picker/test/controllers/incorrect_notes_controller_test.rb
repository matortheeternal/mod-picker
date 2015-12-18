require 'test_helper'

class IncorrectNotesControllerTest < ActionController::TestCase
  setup do
    @incorrect_note = incorrect_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:incorrect_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create incorrect_note" do
    assert_difference('IncorrectNote.count') do
      post :create, incorrect_note: { cn_id: @incorrect_note.cn_id, in_id: @incorrect_note.in_id, inc_id: @incorrect_note.inc_id, r_id: @incorrect_note.r_id, reason: @incorrect_note.reason, submitted_by: @incorrect_note.submitted_by }
    end

    assert_redirected_to incorrect_note_path(assigns(:incorrect_note))
  end

  test "should show incorrect_note" do
    get :show, id: @incorrect_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @incorrect_note
    assert_response :success
  end

  test "should update incorrect_note" do
    patch :update, id: @incorrect_note, incorrect_note: { cn_id: @incorrect_note.cn_id, in_id: @incorrect_note.in_id, inc_id: @incorrect_note.inc_id, r_id: @incorrect_note.r_id, reason: @incorrect_note.reason, submitted_by: @incorrect_note.submitted_by }
    assert_redirected_to incorrect_note_path(assigns(:incorrect_note))
  end

  test "should destroy incorrect_note" do
    assert_difference('IncorrectNote.count', -1) do
      delete :destroy, id: @incorrect_note
    end

    assert_redirected_to incorrect_notes_path
  end
end

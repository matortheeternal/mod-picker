require 'test_helper'

class CompatibilityNotesControllerTest < ActionController::TestCase
  setup do
    @compatibility_note = compatibility_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:compatibility_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create compatibility_note" do
    assert_difference('CompatibilityNote.count') do
      post :create, compatibility_note: { compatibility_patch: @compatibility_note.compatibility_patch, compatibility_status: @compatibility_note.compatibility_status, id: @compatibility_note.id, mod_mode: @compatibility_note.mod_mode, submitted_by: @compatibility_note.submitted_by }
    end

    assert_redirected_to compatibility_note_path(assigns(:compatibility_note))
  end

  test "should show compatibility_note" do
    get :show, id: @compatibility_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @compatibility_note
    assert_response :success
  end

  test "should update compatibility_note" do
    patch :update, id: @compatibility_note, compatibility_note: { compatibility_patch: @compatibility_note.compatibility_patch, compatibility_status: @compatibility_note.compatibility_status, id: @compatibility_note.id, mod_mode: @compatibility_note.mod_mode, submitted_by: @compatibility_note.submitted_by }
    assert_redirected_to compatibility_note_path(assigns(:compatibility_note))
  end

  test "should destroy compatibility_note" do
    assert_difference('CompatibilityNote.count', -1) do
      delete :destroy, id: @compatibility_note
    end

    assert_redirected_to compatibility_notes_path
  end
end

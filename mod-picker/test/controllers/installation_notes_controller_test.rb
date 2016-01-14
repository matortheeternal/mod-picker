require 'test_helper'

class InstallationNotesControllerTest < ActionController::TestCase
  setup do
    @installation_note = installation_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:installation_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create installation_note" do
    assert_difference('InstallationNote.count') do
      post :create, installation_note: { always: @installation_note.always, edited: @installation_note.edited, in_id: @installation_note.in_id, mv_id: @installation_note.mv_id, note_type: @installation_note.note_type, submitted: @installation_note.submitted, submitted_by: @installation_note.submitted_by, text_body: @installation_note.text_body }
    end

    assert_redirected_to installation_note_path(assigns(:installation_note))
  end

  test "should show installation_note" do
    get :show, id: @installation_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @installation_note
    assert_response :success
  end

  test "should update installation_note" do
    patch :update, id: @installation_note, installation_note: { always: @installation_note.always, edited: @installation_note.edited, in_id: @installation_note.in_id, mv_id: @installation_note.mv_id, note_type: @installation_note.note_type, submitted: @installation_note.submitted, submitted_by: @installation_note.submitted_by, text_body: @installation_note.text_body }
    assert_redirected_to installation_note_path(assigns(:installation_note))
  end

  test "should destroy installation_note" do
    assert_difference('InstallationNote.count', -1) do
      delete :destroy, id: @installation_note
    end

    assert_redirected_to installation_notes_path
  end
end

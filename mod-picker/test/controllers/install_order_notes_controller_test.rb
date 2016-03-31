require 'test_helper'

class InstallOrderNotesControllerTest < ActionController::TestCase
  setup do
    install_order_note = install_order_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:install_order_note)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create install_order_note" do
    assert_difference('InstallOrderNote.count') do
      post :create, install_order_note: {always: install_order_note.always, edited: install_order_note.edited, id: install_order_note.id, mod_version_id: install_order_note.mod_version_id, note_type: install_order_note.note_type, submitted: install_order_note.submitted, submitted_by: install_order_note.submitted_by, text_body: install_order_note.text_body }
    end

    assert_redirected_to install_order_note_path(assigns(:install_order_note))
  end

  test "should show install_order_note" do
    get :show, id: install_order_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: install_order_note
    assert_response :success
  end

  test "should update install_order_note" do
    patch :update, id: install_order_note, install_order_note: {always: install_order_note.always, edited: install_order_note.edited, id: install_order_note.id, mod_version_id: install_order_note.mod_version_id, note_type: install_order_note.note_type, submitted: install_order_note.submitted, submitted_by: install_order_note.submitted_by, text_body: install_order_note.text_body }
    assert_redirected_to install_order_note_path(assigns(:install_order_note))
  end

  test "should destroy install_order_note" do
    assert_difference('InstallOrderNote.count', -1) do
      delete :destroy, id: install_order_note
    end

    assert_redirected_to install_order_notes_path
  end
end

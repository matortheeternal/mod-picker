require 'test_helper'

class ModListInstallationNotesControllerTest < ActionController::TestCase
  setup do
    @mod_list_installation_note = mod_list_installation_notes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_list_installation_notes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_list_installation_note" do
    assert_difference('ModListInstallationNote.count') do
      post :create, mod_list_installation_note: { installation_note_id: @mod_list_installation_note.installation_note_id, mod_list_id: @mod_list_installation_note.mod_list_id, status: @mod_list_installation_note.status }
    end

    assert_redirected_to mod_list_installation_note_path(assigns(:mod_list_installation_note))
  end

  test "should show mod_list_installation_note" do
    get :show, id: @mod_list_installation_note
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_list_installation_note
    assert_response :success
  end

  test "should update mod_list_installation_note" do
    patch :update, id: @mod_list_installation_note, mod_list_installation_note: { installation_note_id: @mod_list_installation_note.installation_note_id, mod_list_id: @mod_list_installation_note.mod_list_id, status: @mod_list_installation_note.status }
    assert_redirected_to mod_list_installation_note_path(assigns(:mod_list_installation_note))
  end

  test "should destroy mod_list_installation_note" do
    assert_difference('ModListInstallationNote.count', -1) do
      delete :destroy, id: @mod_list_installation_note
    end

    assert_redirected_to mod_list_installation_notes_path
  end
end

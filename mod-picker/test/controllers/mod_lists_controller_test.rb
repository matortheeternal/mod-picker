require 'test_helper'

class ModListsControllerTest < ActionController::TestCase
  setup do
    @mod_list = mod_lists(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mod_lists)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mod_list" do
    assert_difference('ModList.count') do
      post :create, mod_list: { completed: @mod_list.completed, created: @mod_list.created, created_by: @mod_list.created_by, description: @mod_list.description, game: @mod_list.game, has_adult_content: @mod_list.has_adult_content, is_collection: @mod_list.is_collection, is_public: @mod_list.is_public, ml_id: @mod_list.ml_id, status: @mod_list.status }
    end

    assert_redirected_to mod_list_path(assigns(:mod_list))
  end

  test "should show mod_list" do
    get :show, id: @mod_list
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @mod_list
    assert_response :success
  end

  test "should update mod_list" do
    patch :update, id: @mod_list, mod_list: { completed: @mod_list.completed, created: @mod_list.created, created_by: @mod_list.created_by, description: @mod_list.description, game: @mod_list.game, has_adult_content: @mod_list.has_adult_content, is_collection: @mod_list.is_collection, is_public: @mod_list.is_public, ml_id: @mod_list.ml_id, status: @mod_list.status }
    assert_redirected_to mod_list_path(assigns(:mod_list))
  end

  test "should destroy mod_list" do
    assert_difference('ModList.count', -1) do
      delete :destroy, id: @mod_list
    end

    assert_redirected_to mod_lists_path
  end
end

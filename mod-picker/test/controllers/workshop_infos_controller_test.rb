require 'test_helper'

class WorkshopInfosControllerTest < ActionController::TestCase
  setup do
    @workshop_info = workshop_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:workshop_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create workshop_info" do
    assert_difference('WorkshopInfo.count') do
      post :create, workshop_info: { mod_id: @workshop_info.mod_id, ws_id: @workshop_info.ws_id }
    end

    assert_redirected_to workshop_info_path(assigns(:workshop_info))
  end

  test "should show workshop_info" do
    get :show, id: @workshop_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @workshop_info
    assert_response :success
  end

  test "should update workshop_info" do
    patch :update, id: @workshop_info, workshop_info: { mod_id: @workshop_info.mod_id, ws_id: @workshop_info.ws_id }
    assert_redirected_to workshop_info_path(assigns(:workshop_info))
  end

  test "should destroy workshop_info" do
    assert_difference('WorkshopInfo.count', -1) do
      delete :destroy, id: @workshop_info
    end

    assert_redirected_to workshop_infos_path
  end
end

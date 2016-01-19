require 'test_helper'

class LoverInfosControllerTest < ActionController::TestCase
  setup do
    @lover_info = lover_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lover_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lover_info" do
    assert_difference('LoverInfo.count') do
      post :create, lover_info: { id: @lover_info.id, mod_id: @lover_info.mod_id }
    end

    assert_redirected_to lover_info_path(assigns(:lover_info))
  end

  test "should show lover_info" do
    get :show, id: @lover_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lover_info
    assert_response :success
  end

  test "should update lover_info" do
    patch :update, id: @lover_info, lover_info: { id: @lover_info.id, mod_id: @lover_info.mod_id }
    assert_redirected_to lover_info_path(assigns(:lover_info))
  end

  test "should destroy lover_info" do
    assert_difference('LoverInfo.count', -1) do
      delete :destroy, id: @lover_info
    end

    assert_redirected_to lover_infos_path
  end
end

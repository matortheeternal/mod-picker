require 'test_helper'

class ReputationMapsControllerTest < ActionController::TestCase
  setup do
    @reputation_map = reputation_maps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reputation_maps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reputation_map" do
    assert_difference('ReputationMap.count') do
      post :create, reputation_map: { from_rep_id: @reputation_map.from_rep_id, to_rep_id: @reputation_map.to_rep_id }
    end

    assert_redirected_to reputation_map_path(assigns(:reputation_map))
  end

  test "should show reputation_map" do
    get :show, id: @reputation_map
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @reputation_map
    assert_response :success
  end

  test "should update reputation_map" do
    patch :update, id: @reputation_map, reputation_map: { from_rep_id: @reputation_map.from_rep_id, to_rep_id: @reputation_map.to_rep_id }
    assert_redirected_to reputation_map_path(assigns(:reputation_map))
  end

  test "should destroy reputation_map" do
    assert_difference('ReputationMap.count', -1) do
      delete :destroy, id: @reputation_map
    end

    assert_redirected_to reputation_maps_path
  end
end

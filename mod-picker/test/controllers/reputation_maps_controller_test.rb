require 'test_helper'

class ReputationMapsControllerTest < ActionController::TestCase
  setup do
    @reputation_link = reputation_links(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reputation_links)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create reputation_link" do
    assert_difference('ReputationLink.count') do
      post :create, reputation_link: { from_rep_id: @reputation_link.from_rep_id, to_rep_id: @reputation_link.to_rep_id }
    end

    assert_redirected_to reputation_link_path(assigns(:reputation_link))
  end

  test "should show reputation_link" do
    get :show, id: @reputation_link
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @reputation_link
    assert_response :success
  end

  test "should update reputation_link" do
    patch :update, id: @reputation_link, reputation_link: { from_rep_id: @reputation_link.from_rep_id, to_rep_id: @reputation_link.to_rep_id }
    assert_redirected_to reputation_link_path(assigns(:reputation_link))
  end

  test "should destroy reputation_link" do
    assert_difference('ReputationLink.count', -1) do
      delete :destroy, id: @reputation_link
    end

    assert_redirected_to reputation_links_path
  end
end

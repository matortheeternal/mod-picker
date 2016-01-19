require 'test_helper'

class CategoryPrioritiesControllerTest < ActionController::TestCase
  setup do
    @category_priority = category_priorities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:category_priorities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create category_priority" do
    assert_difference('CategoryPriority.count') do
      post :create, category_priority: { dominant_id: @category_priority.dominant_id, recessive_id: @category_priority.recessive_id }
    end

    assert_redirected_to category_priority_path(assigns(:category_priority))
  end

  test "should show category_priority" do
    get :show, id: @category_priority
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @category_priority
    assert_response :success
  end

  test "should update category_priority" do
    patch :update, id: @category_priority, category_priority: { dominant_id: @category_priority.dominant_id, recessive_id: @category_priority.recessive_id }
    assert_redirected_to category_priority_path(assigns(:category_priority))
  end

  test "should destroy category_priority" do
    assert_difference('CategoryPriority.count', -1) do
      delete :destroy, id: @category_priority
    end

    assert_redirected_to category_priorities_path
  end
end

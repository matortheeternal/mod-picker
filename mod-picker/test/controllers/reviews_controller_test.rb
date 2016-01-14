require 'test_helper'

class ReviewsControllerTest < ActionController::TestCase
  setup do
    @review = reviews(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:reviews)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create review" do
    assert_difference('Review.count') do
      post :create, review: { TINYINT: @review.TINYINT, edited: @review.edited, hidden: @review.hidden, mod_id: @review.mod_id, r_id: @review.r_id, rating1: @review.rating1, rating2: @review.rating2, rating3: @review.rating3, rating4: @review.rating4, submitted: @review.submitted, submitted_by: @review.submitted_by, text_body: @review.text_body }
    end

    assert_redirected_to review_path(assigns(:review))
  end

  test "should show review" do
    get :show, id: @review
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @review
    assert_response :success
  end

  test "should update review" do
    patch :update, id: @review, review: { TINYINT: @review.TINYINT, edited: @review.edited, hidden: @review.hidden, mod_id: @review.mod_id, r_id: @review.r_id, rating1: @review.rating1, rating2: @review.rating2, rating3: @review.rating3, rating4: @review.rating4, submitted: @review.submitted, submitted_by: @review.submitted_by, text_body: @review.text_body }
    assert_redirected_to review_path(assigns(:review))
  end

  test "should destroy review" do
    assert_difference('Review.count', -1) do
      delete :destroy, id: @review
    end

    assert_redirected_to reviews_path
  end
end

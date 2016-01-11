require 'test_helper'

class UserReputationsControllerTest < ActionController::TestCase
  setup do
    @user_reputation = user_reputations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_reputations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_reputation" do
    assert_difference('UserReputation.count') do
      post :create, user_reputation: { audiovisual_design: @user_reputation.audiovisual_design, offset: @user_reputation.offset, overall: @user_reputation.overall, plugin_design: @user_reputation.plugin_design, rep_id: @user_reputation.rep_id, script_design: @user_reputation.script_design, user_id: @user_reputation.user_id, utilty_design: @user_reputation.utilty_design }
    end

    assert_redirected_to user_reputation_path(assigns(:user_reputation))
  end

  test "should show user_reputation" do
    get :show, id: @user_reputation
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_reputation
    assert_response :success
  end

  test "should update user_reputation" do
    patch :update, id: @user_reputation, user_reputation: { audiovisual_design: @user_reputation.audiovisual_design, offset: @user_reputation.offset, overall: @user_reputation.overall, plugin_design: @user_reputation.plugin_design, rep_id: @user_reputation.rep_id, script_design: @user_reputation.script_design, user_id: @user_reputation.user_id, utilty_design: @user_reputation.utilty_design }
    assert_redirected_to user_reputation_path(assigns(:user_reputation))
  end

  test "should destroy user_reputation" do
    assert_difference('UserReputation.count', -1) do
      delete :destroy, id: @user_reputation
    end

    assert_redirected_to user_reputations_path
  end
end

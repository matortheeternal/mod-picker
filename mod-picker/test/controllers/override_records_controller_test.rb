require 'test_helper'

class OverrideRecordsControllerTest < ActionController::TestCase
  setup do
    @override_record = override_records(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:override_records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create override_record" do
    assert_difference('OverrideRecord.count') do
      post :create, override_record: { form_id: @override_record.form_id, master_id: @override_record.master_id, plugin_id: @override_record.plugin_id }
    end

    assert_redirected_to override_record_path(assigns(:override_record))
  end

  test "should show override_record" do
    get :show, id: @override_record
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @override_record
    assert_response :success
  end

  test "should update override_record" do
    patch :update, id: @override_record, override_record: { form_id: @override_record.form_id, master_id: @override_record.master_id, plugin_id: @override_record.plugin_id }
    assert_redirected_to override_record_path(assigns(:override_record))
  end

  test "should destroy override_record" do
    assert_difference('OverrideRecord.count', -1) do
      delete :destroy, id: @override_record
    end

    assert_redirected_to override_records_path
  end
end

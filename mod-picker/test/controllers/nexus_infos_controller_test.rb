require 'test_helper'

class NexusInfosControllerTest < ActionController::TestCase
  setup do
    @nexus_info = nexus_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nexus_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nexus_info" do
    assert_difference('NexusInfo.count') do
      post :create, nexus_info: { articles_count: @nexus_info.articles_count, authors: @nexus_info.authors, changelog: @nexus_info.changelog, endorsements: @nexus_info.endorsements, files_count: @nexus_info.files_count, images_count: @nexus_info.images_count, mod_id: @nexus_info.mod_id, nexus_category: @nexus_info.nexus_category, nm_id: @nexus_info.nm_id, posts_count: @nexus_info.posts_count, total_downloads: @nexus_info.total_downloads, unique_downloads: @nexus_info.unique_downloads, uploaded_by: @nexus_info.uploaded_by, videos_count: @nexus_info.videos_count, views: @nexus_info.views }
    end

    assert_redirected_to nexus_info_path(assigns(:nexus_info))
  end

  test "should show nexus_info" do
    get :show, id: @nexus_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nexus_info
    assert_response :success
  end

  test "should update nexus_info" do
    patch :update, id: @nexus_info, nexus_info: { articles_count: @nexus_info.articles_count, authors: @nexus_info.authors, changelog: @nexus_info.changelog, endorsements: @nexus_info.endorsements, files_count: @nexus_info.files_count, images_count: @nexus_info.images_count, mod_id: @nexus_info.mod_id, nexus_category: @nexus_info.nexus_category, nm_id: @nexus_info.nm_id, posts_count: @nexus_info.posts_count, total_downloads: @nexus_info.total_downloads, unique_downloads: @nexus_info.unique_downloads, uploaded_by: @nexus_info.uploaded_by, videos_count: @nexus_info.videos_count, views: @nexus_info.views }
    assert_redirected_to nexus_info_path(assigns(:nexus_info))
  end

  test "should destroy nexus_info" do
    assert_difference('NexusInfo.count', -1) do
      delete :destroy, id: @nexus_info
    end

    assert_redirected_to nexus_infos_path
  end
end

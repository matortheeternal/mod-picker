require 'test_helper'

class GamesControllerTest < ActionController::TestCase
  setup do
    @game = games(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:games)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create game" do
    assert_difference('Game.count') do
      post :create, game: { abbr_name: @game.abbr_name, exe_name: @game.exe_name, id: @game.id, long_name: @game.long_name, short_name: @game.short_name, steam_app_ids: @game.steam_app_ids }
    end

    assert_redirected_to game_path(assigns(:game))
  end

  test "should show game" do
    get :show, id: @game
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @game
    assert_response :success
  end

  test "should update game" do
    patch :update, id: @game, game: { abbr_name: @game.abbr_name, exe_name: @game.exe_name, id: @game.id, long_name: @game.long_name, short_name: @game.short_name, steam_app_ids: @game.steam_app_ids }
    assert_redirected_to game_path(assigns(:game))
  end

  test "should destroy game" do
    assert_difference('Game.count', -1) do
      delete :destroy, id: @game
    end

    assert_redirected_to games_path
  end
end

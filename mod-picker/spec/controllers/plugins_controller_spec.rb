require 'rails_helper'

RSpec.describe PluginsController, :controller do
  describe 'Submit Mod' do
    fixtures :users, :games

    file_name = 'iHUD.esp'
    # path to where file is saved in dev
    file_path = Rails.root.join('app','assets', 'plugins', "Skyrim", file_name)

    before(:each) do
      # file_name = 'iHUD.esp'
      # file_path = Rails.root.join('app','assets', 'plugins', "Skyrim", file_name)

      if File.exists?(file_path)
        FileUtils.rm(file_path)
      end
    end

    it 'should submit a plugin successfully' do
      game_name = 'Skyrim'
      game = games(:skyrim)

      params = {
          # path to spec version of file to upload
          plugin: fixture_file_upload('../assets/plugins/Skyrim/iHUD.esp',
                                      'application/octet-stream', :binary),
          game_id: game.id
      }

      sign_in users(:madoka)

      post :create, params

      expect(response.status).to eq(200)
      expect(File.exists?(file_path)).to be_truthy
    end
  end
end
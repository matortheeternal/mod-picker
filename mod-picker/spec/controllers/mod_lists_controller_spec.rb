require 'rails_helper'

RSpec.describe ModListsController, :controller, :kin do
  fixtures :mod_lists, :mods, :users, :categories, :games

  describe "#tools" do

    let(:list) {mod_lists(:plannedVanilla)}
    let(:game) {games(:skyrim)}

    it "should return only mods with is_utility: true" do

      # create 5 utility mods
      for i in 1..5 do
        # create mod
        mod = create(:mod,
          is_utility: true)
        
        # create mod_list_mod
        mlm = mod.mod_list_mods.create(
          mod_list_id: list.id,
          index: 0)
        
        expect(mlm).to be_valid
        expect(mod).to be_valid
      end

      # create 3 non-mods
      for i in 1..3 do
        # create mod
        mod = create(:mod,
          is_utility: false)
        
        # create mod_list_mod
        mlm = mod.mod_list_mods.create(
          mod_list_id: list.id,
          index: 0)
        
        expect(mlm).to be_valid
        expect(mod).to be_valid
      end

      # check for total of 8 mods to be created
      expect(list.mods.count).to eq(8)

      # GET request to mod_lists/:id/tools
      # Expect response to only include mods who's utility: true'
      get :tools, {'id' => "#{list.id}"}
      expect(response).to have_http_status(200)
      parsed_response = JSON(response.body)

      parsed_response.each do |tool|
        expect(tool["mod"]["is_utility"]).to eq(true)
      end

    end

    it "should return an empty array if no mods have is_utility: true" do
      # create 3 non-mods
      for i in 1..3 do
        # create mod
        mod = create(:mod,
          is_utility: false)
        
        # create mod_list_mod
        mlm = mod.mod_list_mods.create(
          mod_list_id: list.id,
          index: 0)
        
        expect(mlm).to be_valid
        expect(mod).to be_valid
      end

      # GET request to mod_lists/:id/tools
      # Expect response to only include mods who's utility: true'
      get :tools, {'id' => "#{list.id}"}
      expect(response).to have_http_status(200)
      parsed_response = JSON(response.body)

      expect(parsed_response).to be_empty
    end
  end
  # end #tools


  describe "#plugins" do
    let(:test_list) {mod_lists(:plannedVanilla)}
    let(:test_game) {games(:skyrim)}
    let(:test_mod)  {mods(:Apocalypse)}

    it "should return a list of plugins belonging to the mod_list" do
      for i in 1..3 do
        # create plugin
        plugin = create(:plugin,
          game_id: test_game.id,
          mod_id: test_mod.id,
          filename: "valid_plugin_filename_#{i}"
        )

        # create mod_list_plugin
        mlp = plugin.mod_list_plugins.create(
          mod_list_id: test_list.id,
          index: 0)
        
        expect(mlp).to be_valid
      end

      expect(test_list.mod_list_plugins.count).to eq(3)

      get :plugins, {"id" => "#{test_list.id}"}
      expect(response).to have_http_status(200)

      parsed_response = JSON(response.body)

      parsed_response.each do |plug|
        expect(plug["plugin"]["filename"]).to include("valid_plugin_filename")
      end
    end

    it "should return [] empty array if no plugins are found" do
      get :plugins, {"id" => "#{test_list.id}"}
      expect(response).to have_http_status(200)

      parsed_response = JSON(response.body)

      expect(parsed_response).to be_empty
    end
  end
  # end #plugins

  describe "#config" do

    # fixtures
    let(:test_list) {mod_lists(:plannedVanilla)}
    let(:test_game) {games(:skyrim)}

    it "should return all config_files belonging to the mod_list" do
      # create 5 config files associated with the mod_list fixture
      for i in 1..5 do

        # create config_file
        config_file = create(:config_file,
          filename: "valid_config_filename_#{i}"
        )

        expect(config_file).to be_valid

        # create mod_list_config_file
        mlc = test_list.mod_list_config_files.create(
          mod_list_id: test_list.id,
          config_file_id: config_file.id,
          text_body: 'valid config_body text'
        )
        
        expect(mlc).to be_valid
      end

      get :configs, {"id" => "#{test_list.id}"}
      expect(response).to have_http_status(200)

      parsed_response = JSON(response.body)

      parsed_response.each do |returned_config|
        expect(returned_config["config_file"]["filename"]).to include("valid_config_filename")
        expect(returned_config["text_body"]).to include("valid config_body text") 
      end
    end

    it "should return empty if no config_files are associated with the mod_list" do
      get :configs, {"id" => "#{test_list.id}"}
      expect(response).to have_http_status(200)

      parsed_response = JSON(response.body)

      expect(parsed_response).to be_empty
    end
  end
  # end #configs 
end
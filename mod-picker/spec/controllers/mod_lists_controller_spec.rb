require 'rails_helper'

RSpec.describe ModListsController, :controller, :kin do
  fixtures :mod_lists, :mods, :users, :categories, :games

  describe "GET mod_list tools" do

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
end
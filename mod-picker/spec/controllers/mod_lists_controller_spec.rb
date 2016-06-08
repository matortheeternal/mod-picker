require 'rails_helper'

RSpec.describe ModListsController, :controller, :kin do
    fixtures :mod_lists, :mods, :users, :categories

    describe "GET mod_list tools" do
        it "should return @mods with is_utility of true" do
            list = mod_lists(:plannedVanilla)
            # create 5 mods
            for i in 1..5 do
              mod = list.mods.create(attributes_for(:mod)) 
              expect(mod).to be_valid
            end
        end
    end
end
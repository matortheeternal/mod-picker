require 'rails_helper'

RSpec.describe ModList, :model, :wip do

  fixtures :mod_lists

  it "A Modlist should be valid without any fields" do
    # gameSkyrim = Game.create(
    #     short_name: "Skyman",
    #     long_name: "The Elder Scrolls V: Skyman",
    #     abbr_name: "skmm",
    #     exe_name: "TESM.exe",
    #     steam_app_ids: "72854"
    # )

    modlist = ModList.new
    expect(modlist).to be_valid
  end

  it "should have a valid fixture" do
    expect(mod_lists(:plannedVanilla)).to be_valid
    expect(mod_lists(:underConstructionVanilla)).to be_valid
  end

end

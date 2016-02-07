require 'rails_helper'

describe ModList do
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

end

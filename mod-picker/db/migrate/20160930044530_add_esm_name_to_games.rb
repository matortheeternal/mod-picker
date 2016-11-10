class AddEsmNameToGames < ActiveRecord::Migration
  def change
    add_column :games, :esm_name, :string, limit: 32, after: :exe_name

    Game.find_by(abbr_name: "sk").update(esm_name: "Skyrim.esm")
    Game.find_by(abbr_name: "ob").update(esm_name: "Oblivion.esm")
    Game.find_by(abbr_name: "fo4").update(esm_name: "Fallout4.esm")
    Game.find_by(abbr_name: "fo3").update(esm_name: "Fallout3.esm")
    Game.find_by(abbr_name: "fnv").update(esm_name: "FalloutNV.esm")
  end
end

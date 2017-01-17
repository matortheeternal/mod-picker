require "#{Rails.root}/db/static_seeds"

class AddSkyrimSpecialEdition < ActiveRecord::Migration
  def change
    change_column :games, :nexus_name, :string, limit: 32

    mator = User.find(1)
    gameBethesda = Game.find_by(abbr_name: "bg")
    gameSkyrimSE = Game.create(
        parent_game_id: gameBethesda.id,
        display_name: "Skyrim SE",
        long_name: "Skyrim: Special Edition",
        abbr_name: "sse",
        exe_name: "SkyrimSE.exe",
        esm_name: "Skyrim.esm",
        nexus_name: "skyrimspecialedition",
        steam_app_ids: "489830"
    )
    load_record_groups(gameSkyrimSE, "skyrimse.json")
    seed_skyrimse_official_content(mator)
  end
end

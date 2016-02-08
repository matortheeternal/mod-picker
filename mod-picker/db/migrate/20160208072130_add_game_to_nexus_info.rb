class AddGameToNexusInfo < ActiveRecord::Migration
  def change
    add_column :nexus_infos, :game_id, :integer

    reversible do |dir|
      dir.up do
        execute("ALTER TABLE nexus_infos MODIFY game_id INT UNSIGNED")
      end
    end

    add_foreign_key :nexus_infos, :games, column: :game_id
  end
end

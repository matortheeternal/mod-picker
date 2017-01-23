class ActiveModList < ActiveRecord::Base
  include BetterJson

  belongs_to :game
  belongs_to :user, inverse_of: 'active_mod_lists'
  belongs_to :mod_list

  def self.apply(game, user, mod_list)
    if mod_list.present?
      ActiveModList.create(game_id: game, user_id: user.id, mod_list_id: mod_list.id)
    end
  end

  def self.clear(game, user)
    ActiveModList.where(user_id: user.id, game_id: game).delete_all
  end
end

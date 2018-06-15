class ModListAuthor < ActiveRecord::Base
  include Trackable, BetterJson

  # ATTRIBUTES
  enum role: [:author, :contributor, :curator]

  # EVENT TRACKING
  track :added

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :user, to: [:added]
  subscribe :mod_list_author_users, to: [:added]

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_authors'
  belongs_to :user, :inverse_of => 'mod_list_authors'

  # TODO: COUNTER CACHE

  # VALIDATIONS
  validates :mod_list_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :mod_list_id, :message => "Mod List Author duplication is not allowed." }

  def removed_by
    mod_list.edited_by
  end

  def mod_list_author_users
    User.joins(:mod_list_authors).where(mod_list_authors: {role: 0, mod_list_id: mod_list_id})
  end
end
class ModListAuthor < ActiveRecord::Base
  include Trackable, BetterJson, CounterCache

  # ATTRIBUTES
  enum role: [:author, :contributor, :curator]

  # EVENT TRACKING
  track :added

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :user, to: [:added]
  subscribe :mod_list_author_users, to: [:added]

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_authors'
  belongs_to :user, :foreign_key => 'user_id', :inverse_of => 'mod_list_authors'

  # VALIDATIONS
  validates :mod_list_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :mod_list_id, :message => "Mod List Author duplication is not allowed." }

  def self.add_author(mod_list_id, user_id)
    existing_author = ModListAuthor.find_by(mod_list_id: mod_list_id, user_id: user_id)
    existing_author.update(role: 0) if existing_author.present?
    ModListAuthor.create(mod_list_id: mod_list_id, user_id: user_id, role: 0)
  end

  def removed_by
    mod_list.edited_by
  end

  def mod_list_author_users
    User.joins(:mod_list_authors).where(:mod_list_authors => {role: 0, mod_list_id: mod_list_id})
  end
end

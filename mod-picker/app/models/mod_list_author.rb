class ModListAuthor < ActiveRecord::Base
  include Trackable, BetterJson, CounterCache

  # ATTRIBUTES
  enum role: [:author, :contributor]

  # EVENT TRACKING
  track :added

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :user, to: [:added]
  subscribe :mod_list_author_users, to: [:added]
  subscribe :mod_list_submitter, to: [:added]

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_authors'
  belongs_to :user, :foreign_key => 'user_id', :inverse_of => 'mod_list_authors'

  # VALIDATIONS
  validates :mod_list_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :mod_list_id, :message => "Mod List Author duplication is not allowed." }

  # CALLBACKS
  before_destroy :unset_active

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

  def mod_list_submitter
    User.where(id: mod_list.submitted_by)
  end

  private
    def unset_active
      ActiveModList.where(user_id: user_id, mod_list_id: mod_list_id).destroy_all
    end
end

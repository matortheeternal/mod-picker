class ModAuthor < ActiveRecord::Base
  include Trackable, BetterJson

  # ATTRIBUTES
  enum role: [:author, :contributor, :curator]

  # EVENT TRACKING
  track :added

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :mod_author_users, to: [:added]

  # ASSOCIATIONS
  belongs_to :mod, :inverse_of => 'mod_authors'
  belongs_to :user, :foreign_key => 'user_id', :inverse_of => 'mod_authors'

  # VALIDATIONS
  validates :mod_id, :user_id, presence: true
  validates :user_id, uniqueness: { scope: :mod_id, :message => "Mod Author duplication is not allowed." }

  # CALLBACKS
  after_create :increment_counters
  after_save :update_user_role, :hide_reviews
  before_destroy :decrement_counters, :update_user_role, :unhide_reviews

  def self.link_author(model, user_id, username)
    infos = model.where(uploaded_by: username)

    infos.each do |info|
      ModAuthor.find_or_create_by(mod_id: info.mod_id, user_id: user_id) if info.mod_id.present?
    end
  end

  def removed_by
    mod.edited_by
  end

  def mod_author_users
    User.joins(:mod_authors).where(:mod_authors => {role: 0, mod_id: mod_id})
  end

  private
    def decrement_counters
      user.update_counter(:authored_mods_count, -1)
    end

    def update_user_role
      user.update_mod_author_role
    end

    def hide_reviews
      hide = role.to_sym == :curator
      user.reviews.where(mod_id: mod_id).update_all(hidden: hide)
    end

    def unhide_reviews
      user.reviews.where(mod_id: mod_id).update_all(hidden: false)
    end

    def increment_counters
      user.update_counter(:authored_mods_count, 1)
    end
end

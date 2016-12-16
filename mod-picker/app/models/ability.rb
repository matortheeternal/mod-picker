class Ability
  include CanCan::Ability

  def can_do_anything
    can :manage, :all
  end

  def cannot_read_unapproved_content(user)
    cannot :read, CompatibilityNote, approved: false
    cannot :read, InstallOrderNote, approved: false
    cannot :read, LoadOrderNote, approved: false
    cannot :read, Review, approved: false
    cannot :read, Mod, approved: false
    cannot :read, HelpPage, approved: false

    # can read unapproved content they submitted
    can :read, CompatibilityNote, approved: false, submitted_by: user.id
    can :read, InstallOrderNote, approved: false, submitted_by: user.id
    can :read, LoadOrderNote, approved: false, submitted_by: user.id
    can :read, Review, approved: false, submitted_by: user.id
    can :read, Mod, approved: false, submitted_by: user.id
    can :read, HelpPage, approved: false, submitted_by: user.id
  end

  def cannot_read_hidden_content
    cannot :read, Comment, hidden: true
    cannot :read, CompatibilityNote, hidden: true
    cannot :read, InstallOrderNote, hidden: true
    cannot :read, LoadOrderNote, hidden: true
    cannot :read, Review, hidden: true
    cannot :read, Tag, hidden: true
    cannot :read, Mod, hidden: true
    cannot :read, ModList, hidden: true
  end

  def cannot_read_private_mod_lists(user)
    # users that are not admins or moderators
    # cannot read private mod lists unless they submitted them
    cannot :read, ModList, visibility: "visibility_private"
    can :read, ModList, submitted_by: user.id
  end

  def cannot_read_curator_requests(user)
    # cannot read curator requests they didn't make
    cannot :read, CuratorRequest
    can :read, CuratorRequest, user_id: user.id
  end

  def cannot_read_reports
    cannot :read, Report
    cannot :read, BaseReport
  end

  def rep_10_abilities(user, can_contribute)
    can :set_avatar, User, id: user.id
    can :create, HelpPage if can_contribute
  end

  def rep_20_abilities(user, can_contribute)
    return unless can_contribute
    can :create, Tag
    can :create, CuratorRequest
  end

  def rep_40_abilities(user, can_contribute)
    return unless can_contribute
    can :create, Correction
    cannot :create, Correction, { correctable: { submitted_by: user.id } }
    can :create, Correction, { correctable_type: "Mod" }
    can :create, AgreementMark
  end

  def rep_80_abilities(user, can_contribute)
    return unless can_contribute
    can :create, ReputationLink
  end

  def rep_160_abilities(user, can_contribute)
    return unless can_contribute
    can :add_image, Mod
  end

  def rep_320_abilities(user, can_contribute)
    return unless can_contribute
    can :update, CompatibilityNote, { submitter: { inactive?: true } }
    can :update, InstallOrderNote, { submitter: { inactive?: true } }
    can :update, LoadOrderNote, { submitter: { inactive?: true } }
  end

  def rep_640_abilities(user, can_contribute)
    can :set_custom_title, User, id: user.id
  end

  def reputation_abilities(user, can_contribute)
    rep = user.reputation.overall
    rep_10_abilities(user, can_contribute) if rep >= 10
    rep_20_abilities(user, can_contribute) if rep >= 20
    rep_40_abilities(user, can_contribute) if rep >= 40
    rep_80_abilities(user, can_contribute) if rep >= 80
    rep_160_abilities(user, can_contribute) if rep >= 160
    rep_320_abilities(user, can_contribute) if rep >= 320
    rep_1280_abilities(user, can_contribute) if rep >= 1280
  end

  def user_restrictions(user)
    cannot_read_private_mod_lists(user)
    cannot_read_unapproved_content(user)
    cannot_read_hidden_content
    cannot_read_curator_requests(user)
    cannot_read_reports
  end

  def can_manage_users(user)
    can [:assign_roles, :adjust_rep, :invite], User
    can :set_avatar, User, id: user.id
    can :set_custom_title, User, id: user.id
  end

  def can_monitor_site_activity
    can :index, Event
  end

  def can_manage_mods
    # can update or hide any mod
    can [:update, :hide, :approve, :assign_custom_sources, :update_authors, :update_options], Mod
    can :destroy, ModRequirement
    # can approve curator requests
    can :update, CuratorRequest
  end

  def can_manage_help_pages
    # can create, update, and approve help pages
    can [:create, :update, :approve], HelpPage
  end

  def can_manage_mod_lists
    # can hide mod lists
    can :hide, ModList
  end

  def can_manage_contributions
    # can update, approve, or hide any contribution
    can [:update, :hide], Comment
    can [:update, :approve, :hide], CompatibilityNote
    can [:update, :approve, :hide], Correction
    can [:update, :approve, :hide], InstallOrderNote
    can [:update, :approve, :hide], LoadOrderNote
    can [:update, :approve, :hide], Review
    can [:update, :hide], Tag
    # can delete tags
    can :destroy, ModTag
    can :destroy, ModListTag
  end

  def can_manage_reports
    can :resolve, BaseReport
  end

  def moderation_abilities(user)
    can_manage_users(user)
    can_monitor_site_activity
    can_manage_help_pages
    can_manage_mod_lists
    can_manage_mods
    can_manage_contributions
    can_manage_reports
  end

  def can_manage_articles
    can [:create, :update], Article
  end

  def helper_abilities
    can_manage_help_pages
    can_manage_mods
  end

  def can_create_new_contributions
    can :create, HelpfulMark
    can :create, CompatibilityNote
    can :create, InstallOrderNote
    can :create, LoadOrderNote
    can :create, Review
    can :create, ModTag
    can :create, ModListTag
  end

  def can_submit_reports
    can :create, Report
    can :create, BaseReport
  end

  def can_submit_mods
    can :create, Mod
  end

  def can_update_their_contributions(user)
    can :update, CompatibilityNote, submitted_by: user.id, hidden: false
    can :update, Correction, submitted_by: user.id, hidden: false
    can :update, LoadOrderNote, submitted_by: user.id, hidden: false
    can :update, InstallOrderNote, submitted_by: user.id, hidden: false
    can :update, Review, submitted_by: user.id, hidden: false
    can :update, HelpPage, submitted_by: user.id

    # can update contributions they have a passed correction for
    can :update, CompatibilityNote, corrector_id: user.id, hidden: false
    can :update, LoadOrderNote, corrector_id: user.id, hidden: false
    can :update, InstallOrderNote, corrector_id: user.id, hidden: false

    # can remove tags they created
    can :destroy, ModTag, submitted_by: user.id
    can :destroy, ModListTag, submitted_by: user.id
  end

  def can_manage_their_marks(user)
    can [:update, :destroy], AgreementMark, submitted_by: user.id
    can [:update, :destroy], HelpfulMark, submitted_by: user.id
  end

  def mod_author_abilities(user)
    can [:update, :hide], Mod, { mod_authors: { user_id: user.id } }
    can :destroy, ModRequirement, {mod_version: {mod: {mod_authors: {user_id: user.id } } } }
    can :destroy, ModTag, { mod: { mod_authors: { user_id: user.id } } }
    # authors
    can :update_authors, Mod, { mod_authors: { user_id: user.id, role: 0 } }
    can :update_options, Mod, { mod_authors: { user_id: user.id, role: 0 } }
    can :change_status, Mod, { status: 0, mod_authors: { user_id: user.id, role: 0 } }
    can [:read, :update], CuratorRequest, { mod: { mod_authors: { user_id: user.id, role: 0 } } }
    # contributors
    cannot [:update, :hide], Mod, { disallow_contributors: true, mod_authors: { user_id: user.id, role: 1 } }
  end

  def contributor_abilities(user)
    can_create_new_contributions
    can_submit_reports
    can_submit_mods
    can_update_their_contributions(user)
    can_manage_their_marks(user)
    mod_author_abilities(user)
    reputation_abilities(user, true)
  end

  def can_comment_on_things(user)
    can :create, Comment
    can :update, Comment, submitted_by: user.id, hidden: false
  end

  def can_star_things(user)
    can :create, ModStar
    can :create, ModListStar
    can :destroy, ModStar, user_id: user.id
    can :destroy, ModListStar, user_id: user.id
  end

  def can_manage_their_mod_lists(user)
    can :create, ModList
    can [:update, :hide], ModList, submitted_by: user.id, hidden: false
  end

  def can_update_their_settings(user)
    can :update, User, { id: user.id }
    can :update, UserSetting, { user_id: user.id }
    can :update, UserBio, { user_id: user.id }
  end

  def user_abilities(user, can_contribute)
    can_comment_on_things(user)
    can_star_things(user)
    can_manage_their_mod_lists(user)
    can_update_their_settings(user)
    reputation_abilities(user, can_contribute)
  end

  def adult_content_filtering(user)
    settings = user.settings
    unless settings.present? && settings.allow_adult_content
      cannot :read, Mod, { has_adult_content: true }
      cannot :read, Plugin, { has_adult_content: true }
      cannot :read, ModList, { has_adult_content: true }
      cannot :read, Review, { has_adult_content: true }
      cannot :read, CompatibilityNote, { has_adult_content: true }
      cannot :read, InstallOrderNote, { has_adult_content: true }
      cannot :read, LoadOrderNote, { has_adult_content: true }
      cannot :read, Comment, { has_adult_content: true }
      cannot :read, Correction, { has_adult_content: true }
    end
  end

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    user_signed_in = User.exists?(user.id)
    can_contribute = user_signed_in && !user.banned? && !user.restricted?
    can_use = user_signed_in && !user.banned?

    # general read permissions
    can :read, :all

    # staff permissions
    can_do_anything if user.admin?
    moderation_abilities(user) if user.can_moderate?
    user_restrictions(user) unless user.can_moderate?
    can_manage_articles if user.news_writer? || user.admin?
    helper_abilities if user.helper?

    # general permissions
    contributor_abilities(user) if can_contribute
    user_abilities(user, can_contribute) if can_use
    adult_content_filtering(user)
  end
end

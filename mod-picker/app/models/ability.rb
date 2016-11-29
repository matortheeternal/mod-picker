class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    # general read permissions
    can :read, :all

    # admins can do whatever they want
    if user.admin?
      can :manage, :all
    end

    if user.moderator? || user.admin?
      # special moderator permissions
      can [:assign_roles, :adjust_rep, :invite], User
      can :set_avatar, User, id: user.id
      can :set_custom_title, User, id: user.id
      can :index, Event

      # can create and update help pages
      can [:approve, :create, :update], HelpPage

      # can hide mod lists
      can :hide, ModList

      # can update or hide any mod
      can [:update, :hide, :approve, :assign_custom_sources, :update_authors, :update_options], Mod
      can :destroy, ModRequirement

      # can update, approve, or hide any contribution
      can [:update, :hide], Comment
      can [:update, :approve, :hide], CompatibilityNote
      can [:update, :approve, :hide], Correction
      can [:update, :approve, :hide], InstallOrderNote
      can [:update, :approve, :hide], LoadOrderNote
      can [:update, :approve, :hide], Review
      can [:update, :hide], Tag

      # can approve/deny curator requests
      can :update, CuratorRequest

      # can delete tags
      can :destroy, ModTag
      can :destroy, ModListTag

      # can resolve/unresolve reports
      can :resolve, BaseReport
    else
      # users that are not admins or moderators
      # cannot read private mod lists unless they submitted them
      cannot :read, ModList, visibility: "visibility_private"
      can :read, ModList, submitted_by: user.id

      # cannot read unapproved content
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

        # cannot read hidden content
      cannot :read, Comment, hidden: true
      cannot :read, CompatibilityNote, hidden: true
      cannot :read, InstallOrderNote, hidden: true
      cannot :read, LoadOrderNote, hidden: true
      cannot :read, Review, hidden: true
      cannot :read, Tag, hidden: true
      cannot :read, Mod, hidden: true
      cannot :read, ModList, hidden: true

      # cannot read curator requests they didn't make
      cannot :read, CuratorRequest
      can :read, CuratorRequest, user_id: user.id

      # cannot read reports
      cannot :read, Report
      cannot :read, BaseReport
    end

    # news writers and admins can create and update articles
    if user.news_writer? || user.admin?
      can [:create, :update], Article
    end

    # signed in users who aren't restricted or banned
    user_signed_in = User.exists?(user.id)
    if user_signed_in && !user.banned? && !user.restricted?
      # can create new contributions
      can :create, HelpfulMark
      can :create, CompatibilityNote
      can :create, InstallOrderNote
      can :create, LoadOrderNote
      can :create, Review
      can :create, ModTag
      can :create, ModListTag

      #can sumbit reports
      can :create, Report
      can :create, BaseReport

      # can submit mods
      can :create, Mod

      # can update their contributions
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

      # can update or remove their helpful/agreement marks
      can [:update, :destroy], AgreementMark, submitted_by: user.id
      can [:update, :destroy], HelpfulMark, submitted_by: user.id

      # can remove tags they created
      can :destroy, ModTag, submitted_by: user.id
      can :destroy, ModListTag, submitted_by: user.id

      # abilities for mod authors
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

      # abilities tied to reputation
      if user.reputation.overall >= 10
        # can create new help pages
        can :create, HelpPage
      end
      if user.reputation.overall >= 20
        # can create new tags and curator requests
        can :create, Tag
        can :create, CuratorRequest
      end
      if user.reputation.overall >= 40
        # can report something as incorrect unless they submitted it and
        # it is not a mod
        can :create, Correction
        cannot :create, Correction, { correctable: { submitted_by: user.id } }
        can :create, Correction, { correctable_type: "Mod" }

        # can agree/disagree with corrections
        can :create, AgreementMark
      end
      if user.reputation.overall >= 80
        # can give reputation other users
        can :create, ReputationLink
      end
      if user.reputation.overall >= 160
        # can add images to mods that have none
        can :add_image, Mod
      end
      if user.reputation.overall >= 320
        # can update compatibility notes, install order notes, and
        # load order notes when the user who created them is inactive
        can :update, CompatibilityNote, { submitter: { inactive?: true } }
        can :update, InstallOrderNote, { submitter: { inactive?: true } }
        can :update, LoadOrderNote, { submitter: { inactive?: true } }
      end
    end

    # Users that are not banned
    if user_signed_in && !user.banned?
      # can comment on things and update their comments
      can :create, Comment
      can :update, Comment, submitted_by: user.id, hidden: false

      # can star and unstar mods and mod lists
      can :create, ModStar
      can :create, ModListStar
      can :destroy, ModStar, user_id: user.id
      can :destroy, ModListStar, user_id: user.id

      # can create and update their mod lists
      can :create, ModList
      can [:update, :hide], ModList, submitted_by: user.id, hidden: false

      # can update their settings or their account
      can :update, User, { id: user.id }
      can :update, UserSetting, { user_id: user.id }
      can :update, UserBio, { user_id: user.id }

      # abilities tied to reputation
      if user.reputation.overall >= 10
        can :set_avatar, User, id: user.id  # custom avatar
      end
      if user.reputation.overall >= 1280
        can :set_custom_title, User, id: user.id # can set a custom user title
      end
    end

    # Adult content filtering
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
end

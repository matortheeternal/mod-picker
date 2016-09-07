class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    # general read permissions
    can :read, :all

    if user.admin?
      # special admin permissions
      can :assign_roles, User

      # admins can do whatever they want
      can :manage, :all
    end

    if user.moderator? || user.admin?
      # special moderator permissions
      can :ban, User
      can :set_avatar, User, :id => user.id
      can :set_custom_title, User, :id => user.id

      # can create and update help pages
      can [:create, :update], HelpPage

      # can hide mod lists
      can :hide, ModList

      # can update or hide any mod
      can [:update, :hide, :assign_custom_sources, :update_authors, :update_options], Mod
      can :destroy, ModRequirement

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
    else
      # users that are not admins or moderators
      # cannot read private mod lists unless they submitted them
      cannot :read, ModList, :visibility => "visibility_private"
      can :read, ModList, :submitted_by => user.id

      # cannot read unapproved content
      cannot :read, CompatibilityNote, :approved => false
      cannot :read, InstallOrderNote, :approved => false
      cannot :read, LoadOrderNote, :approved => false
      cannot :read, Review, :approved => false

      # can read unapproved content they submitted
      can :read, CompatibilityNote, :approved => false, :submitted_by => user.id
      can :read, InstallOrderNote, :approved => false, :submitted_by => user.id
      can :read, LoadOrderNote, :approved => false, :submitted_by => user.id
      can :read, Review, :approved => false, :submitted_by => user.id

        # cannot read hidden content
      cannot :read, Comment, :hidden => true
      cannot :read, CompatibilityNote, :hidden => true
      cannot :read, InstallOrderNote, :hidden => true
      cannot :read, LoadOrderNote, :hidden => true
      cannot :read, Review, :hidden => true
      cannot :read, ModTag, :hidden => true
      cannot :read, ModListTag, :hidden => true
      cannot :read, Mod, :hidden => true
      cannot :read, ModList, :hidden => true
    end

    # signed in users who aren't banned
    if  User.exists?(user.id) && !user.banned?
      # can create new contributions
      can :create, Comment
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
      can :submit, :mod
      can :create, NexusInfo
      can :create, Mod

      # can update their contributions
      can :update, Comment, :submitted_by => user.id, :hidden => false
      can :update, CompatibilityNote, :submitted_by => user.id, :hidden => false
      can :update, Correction, :submitted_by => user.id, :hidden => false
      can :update, LoadOrderNote, :submitted_by => user.id, :hidden => false
      can :update, InstallOrderNote, :submitted_by => user.id, :hidden => false
      can :update, Review, :submitted_by => user.id, :hidden => false

      # can update contributions they have a passed correction for
      can :update, CompatibilityNote, :corrector_id => user.id, :hidden => false
      can :update, LoadOrderNote, :corrector_id => user.id, :hidden => false
      can :update, InstallOrderNote, :corrector_id => user.id, :hidden => false

      # can update or remove their helpful/agreement marks
      can [:update, :destroy], AgreementMark, :submitted_by => user.id
      can [:update, :destroy], HelpfulMark, :submitted_by => user.id

      # can remove tags they created
      can :destroy, ModTag, :submitted_by => user.id
      can :destroy, ModListTag, :submitted_by => user.id

      # can star and unstar mods and mod lists
      can :create, ModStar
      can :create, ModListStar
      can :destroy, ModStar, :user_id => user.id
      can :destroy, ModListStar, :user_id => user.id

      # can create and update their mod lists
      can :create, ModList
      can [:update, :hide], ModList, :submitted_by => user.id, :hidden => false

      # can update their settings or their account
      can :update, User, { :id => user.id }
      can :update, UserSetting, { :user_id => user.id }
      can :update, UserBio, { :user_id => user.id }

      # abilities for mod authors
      can [:update, :hide], Mod, { :mod_authors => { :user_id => user.id } }
      cannot [:update, :hide], Mod, { :disallow_contributors => true, :mod_authors => { :user_id => user.id, :role => 1 } }
      can :destroy, ModRequirement, {:mod_version => {:mod => {:mod_authors => {:user_id => user.id } } } }
      can :destroy, ModTag, { :mod => { :mod_authors => { :user_id => user.id } } }
      can :update_authors, Mod, { :mod_authors => { :user_id => user.id, :role => 0 } }
      can :update_options, Mod, { :mod_authors => { :user_id => user.id, :role => 1 } }

      # abilities tied to reputation
      if user.reputation.overall >= 20
        can :set_avatar, User, :id => user.id  # custom avatar
        can :create, Tag # can create new tags
      end
      if user.reputation.overall >= 40
        can :create, Correction  # can report something as incorrect
        can :create, AgreementMark  # can agree/disagree with other users
        can :create, ReputationLink # can give reputation other users
      end
      if user.reputation.overall >= 160
        # TODO: mod submission here after the beta
      end
      if user.reputation.overall >= 320
        # can update compatibility notes, install order notes, and load order notes  when the user
        # who created them is inactive
        can :update, CompatibilityNote, { :submitter => { :inactive? => true } }
        can :update, InstallOrderNote, { :submitter => { :inactive? => true } }
        can :update, LoadOrderNote, { :submitter => { :inactive? => true } }
        # or when the community has agreed they are incorrect
        # can :update, CompatibilityNote, { :incorrect? => true }
        # can :update, InstallOrderNote, { :incorrect? => true }
        # can :update, LoadOrderNote, { :incorrect? => true }
      end
      if user.reputation.overall >= 640
        # TODO: Add some stuff here?
      end
      if user.reputation.overall >= 1280
        can :set_custom_title, User, :id => user.id # can set a custom user title
      end
    end

    # Adult content filtering
    if user.settings.present? && !user.settings.allow_adult_content
      cannot :read, Mod, { :has_adult_content => true }
      cannot :read, ModList, { :has_adult_content => true }
      # TODO: filtering of contributions on mods with adult content
    end
  end
end

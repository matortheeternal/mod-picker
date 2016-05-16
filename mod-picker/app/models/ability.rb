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
      can [:update, :hide], Mod
      can :destroy, ModRequirement

      # can update, approve, or hide any contribution
      can [:update, :hide], Comment
      can [:update, :approve, :hide], CompatibilityNote
      can [:update, :approve, :hide], IncorrectNote
      can [:update, :approve, :hide], InstallOrderNote
      can [:update, :approve, :hide], LoadOrderNote
      can [:update, :approve, :hide], Review
      can [:update, :hide], Tag

      # can delete tags
      can :destroy, ModTag
      can :destroy, ModListTag
    else
      # users that are not admins or moderators
      # cannot read hidden content
      cannot :read, Comment, :hidden => true
      cannot :read, CompatibilityNote, :hidden => true
      cannot :read, InstallOrderNote, :hidden => true
      cannot :read, LoadOrderNote, :hidden => true
      cannot :read, Review, :hidden => true
      cannot :read, ModTag, :hidden => true
      cannot :read, ModListTag, :hidden => true
      cannot :read, Mod, :hidden => true

      # cannot read unapproved content
      cannot :read, Comment, :approved => false
      cannot :read, CompatibilityNote, :approved => false
      cannot :read, InstallOrderNote, :approved => false
      cannot :read, LoadOrderNote, :approved => false
      cannot :read, Review, :approved => false
      cannot :read, ModTag, :approved => false
      cannot :read, ModListTag, :approved => false
      cannot :read, Mod, :approved => false
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

      # can submit mods
      can :submit, :mod
      can :create, NexusInfo
      can :create, Mod

      # can update their contributions
      can :update, Comment, :submitted_by => user.id
      can :update, CompatibilityNote, :submitted_by => user.id
      can :update, IncorrectNote, :submitted_by => user.id
      can :update, LoadOrderNote, :submitted_by => user.id
      can :update, InstallOrderNote, :submitted_by => user.id
      can :update, Review, :submitted_by => user.id

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
      can :update, ModList, :submitted_by => user.id

      # can create stuff associated with their mod list
      can :create, ModListMod
      can :create, ModListPlugin
      can :create, ModListCustomPlugin
      can :create, ModListConfigFile
      can :create, ModListCustomConfigFile

      # can update stuff associated with their mod lists
      can :update, ModListMod, { :mod_list => { :created_by => user.id } }
      can :update, ModListPlugin, { :mod_list => { :created_by => user.id } }
      can :update, ModListCustomPlugin, { :mod_list => { :created_by => user.id } }
      can :update, ModListConfigFile, { :mod_list => { :created_by => user.id } }
      can :update, ModListCustomConfigFile, { :mod_list => { :created_by => user.id } }
      can :update, ModListCompatibilityNote, { :mod_list => { :created_by => user.id } }
      can :update, ModListInstallOrderNote, { :mod_list => { :created_by => user.id } }
      can :update, ModListLoadOrderNote, { :mod_list => { :created_by => user.id } }

      # can delete stuff associated with their mod lists
      can :destroy, ModListTag, { :mod_list => { :created_by => user.id }}
      can :destroy, ModListMod, { :mod_list => { :created_by => user.id } }
      can :destroy, ModListPlugin, { :mod_list => { :created_by => user.id } }
      can :destroy, ModListCustomPlugin, { :mod_list => { :created_by => user.id } }
      can :destroy, ModListConfigFile, { :mod_list => { :created_by => user.id } }
      can :destroy, ModListCustomConfigFile, { :mod_list => { :created_by => user.id } }

      # can update their settings or their account
      can :update, User, { :id => user.id }
      can :update, UserSetting, { :user_id => user.id }
      can :update, UserBio, { :user_id => user.id }

      # abilities for mod authors
      can :update, Mod, { :mod_authors => { :user_id => user.id } }
      can :destroy, ModRequirement, {:mod_version => {:mod => {:mod_authors => {:user_id => user.id } } } }
      can :destroy, ModTag, { :mod => { :mod_authors => { :user_id => user.id } } }

      # abilities tied to reputation
      if user.reputation.overall >= 20
        can :set_avatar, User, :id => user.id  # custom avatar
        can :create, Tag # can create new tags
      end
      if user.reputation.overall >= 40
        can :create, IncorrectNote  # can report something as incorrect
        can :create, AgreementMark  # can agree/disagree with other users
        can :create, ReputationLink # can give reputation other users
      end
      if user.reputation.overall >= 160
        # TODO: mod submission here after the beta
      end
      if user.reputation.overall >= 320
        # can update compatibility notes, install order notes, and load order notes  when the user
        # who created them is inactive
        can :update, CompatibilityNote, { :user => { :inactive? => true } }
        can :update, InstallOrderNote, { :user => { :inactive? => true } }
        can :update, LoadOrderNote, { :user => { :inactive? => true } }
        # or when the community has agreed they are incorrect
        can :update, CompatibilityNote, { :incorrect? => true }
        can :update, InstallOrderNote, { :incorrect? => true }
        can :update, LoadOrderNote, { :incorrect? => true }
      end
      if user.reputation.overall >= 640
        can :rescrape, Mod # can request mods be re-scraped
        # can update mods that don't have a verified author
        can :update, Mod, { :no_author? => true }
        can :destroy, ModRequirement, {:mod_version => {:mod => {:no_author? => true } } }
        can :destroy, ModTag, { :mod => { :no_author? => true } }
      end
      if user.reputation.overall >= 1280
        can :set_custom_title, User, :id => user.id # can set a custom user title
      end
    end
  end
end

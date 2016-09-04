class Mod < ActiveRecord::Base
  include Filterable, Sortable, Imageable, RecordEnhancements, SourceHelpers, ScopeHelpers

  enum status: [ :good, :outdated, :unstable ]

  # SCOPES
  include_scope :hidden
  include_scope :adult, :alias => 'include_adult'
  include_scope :is_official, :alias => 'include_official'
  include_scope :is_utility, :alias => 'include_utilities'
  value_scope :is_utility
  game_scope :parent => true
  search_scope :name, :aliases, :combine => true
  ids_scope :categories, :columns => [:primary_category_id, :secondary_category_id]
  user_scope :author_users, :alias => 'mp_author'
  enum_scope :status
  counter_scope :plugins_count, :asset_files_count, :required_mods_count, :required_by_count, :tags_count, :stars_count, :mod_lists_count, :reviews_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :corrections_count
  source_scope :views, :sites =>  [:nexus, :lab, :workshop]
  source_scope :downloads, :sites => [:nexus, :lab]
  source_scope :file_size, :sites => [:nexus, :lab]
  source_scope :posts, :sites => [:nexus, :workshop], :alias => [:posts_count, :comments_count]
  source_scope :videos, :sites => [:nexus, :workshop], :alias => [:videos_count, :videos_count]
  source_scope :images, :sites => [:nexus, :workshop], :alias => [:images_count, :images_count]
  source_scope :favorites, :sites => [:lab, :workshop], :alias => [:followers_count, :favorites]
  source_scope :discussions, :sites => [:nexus, :workshop]
  source_scope :endorsements, :sites => [:nexus]
  source_scope :unique_downloads, :sites => [:nexus]
  source_scope :files, :sites => [:nexus], :alias => [:files_count]
  source_scope :bugs, :sites => [:nexus], :alias => [:bugs_count]
  source_scope :articles, :sites => [:nexus], :alias => [:articles_count]
  source_scope :subscribers, :sites => [:workshop]

  # UNIQUE SCOPES
  scope :include_games, -> (bool) { where.not(primary_category_id: nil) if !bool }
  }
  scope :exclude, -> (excluded_mod_ids) { where.not(id: excluded_mod_ids) }
  scope :sources, -> (sources) {
    # TODO: Use AREL for this?
    query = where(nil)
    where_clause = []

    sources.each_key do |key|
      if sources[key]
        table = get_source_table(key)
        query = query.includes(table).references(table)
        where_clause.push("#{table}.id IS NOT NULL")
      end
    end

    query.where(where_clause.join(" OR "))
  }
  scope :tags, -> (array) { joins(:tags).where(:tags => {text: array}).having("COUNT(DISTINCT tags.text) = ?", array.length) }
  scope :author, -> (hash) {
    # TODO: Use AREL for this?
    author = hash[:value]
    sources = hash[:sources]
    where_clause = []

    results = where_clause.push("nexus_infos.authors like :author OR nexus_infos.uploaded_by like :author") if sources[:nexus]
    results = where_clause.push("lover_infos.uploaded_by like :author") if sources[:lab]
    results = where_clause.push("workshop_infos.uploaded_by like :author") if sources[:workshop]
    results = where_clause.push("mods.authors like :author") if sources[:other]

    where(where_clause.join(" OR "))
  }

  belongs_to :game, :inverse_of => 'mods'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'submitted_mods'

  # categories the mod belongs to
  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'primary_category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'secondary_category_id', :inverse_of => 'secondary_mods'

  # site statistics associated with the mod
  has_one :nexus_infos, :class_name => 'NexusInfo', :dependent => :nullify
  has_one :lover_infos, :class_name => 'LoverInfo', :dependent => :nullify
  has_one :workshop_infos, :class_name => 'WorkshopInfo', :dependent => :nullify

  # custom sources
  has_many :custom_sources, :inverse_of => 'mod', :dependent => :destroy

  # mod options
  has_many :mod_options, :inverse_of => 'mod', :dependent => :destroy
  # plugins associated with the mod
  has_many :plugins, :inverse_of => 'mod', :through => 'mod_options'
  # assets associated with the mod
  has_many :mod_asset_files, :inverse_of => 'mod', :through => 'mod_options'
  has_many :asset_files, :through => :mod_asset_files, :inverse_of => 'mods'

  # requirements associated with the mod
  has_many :required_mods, :class_name => 'ModRequirement', :inverse_of => 'mod', :dependent => :destroy
  has_many :required_by, :class_name => 'ModRequirement', :inverse_of => 'required_mod', :foreign_key => 'required_id', :dependent => :destroy

  # config files associated with the mod
  has_many :config_files, :inverse_of => 'mod', :dependent => :destroy

  # users who can edit the mod
  has_many :mod_authors, :inverse_of => 'mod', :dependent => :destroy
  has_many :author_users, :class_name => 'User', :through => 'mod_authors', :source => 'user', :inverse_of => 'mods'

  # community feedback on the mod
  has_many :corrections, :as => 'correctable'
  has_many :reviews, :inverse_of => 'mod', :dependent => :destroy
  has_many :mod_stars, :inverse_of => 'mod', :dependent => :destroy
  has_many :user_stars, :through => 'mod_stars', :class_name => 'User', :inverse_of => 'starred_mods'

  # tags
  has_many :mod_tags, :inverse_of => 'mod', :dependent => :destroy
  has_many :tags, :through => 'mod_tags', :inverse_of => 'mods'

  # notes
  has_many :compatibility_notes, -> (mod) {
    where('first_mod_id = :mod_id OR second_mod_id = :mod_id', mod_id: mod.id)
  }
  has_many :install_order_notes, -> (mod) {
    where('first_mod_id = :mod_id OR second_mod_id = :mod_id', mod_id: mod.id)
  }
  has_many :load_order_notes, -> (mod) {
    where('first_plugin_id in (:plugin_ids) OR second_plugin_id in (:plugin_ids)', plugin_ids: mod.plugins.ids)
  }

  # mod list usage
  has_many :mod_list_mods, :inverse_of => 'mod', :dependent => :destroy
  has_many :mod_lists, :through => 'mod_list_mods', :inverse_of => 'mods'

  accepts_nested_attributes_for :custom_sources, allow_destroy: true
  accepts_nested_attributes_for :config_files, allow_destroy: true
  # cannot update required mods
  accepts_nested_attributes_for :required_mods, reject_if: proc {
      |attributes| attributes[:id] && !attributes[:_destroy]
  }, allow_destroy: true
  # can only update author role for an existing mod_author record
  accepts_nested_attributes_for :mod_authors, reject_if: proc {
      |attributes| attributes[:id] && attributes[:user_id] && !attributes[:_destroy]
  }, allow_destroy: true

  # numbers of mods per page on the mods index
  self.per_page = 100

  # VALIDATIONS
  validates :game_id, :submitted_by, :name, :authors, :released, presence: true
  validates :name, :aliases, length: {maximum: 128}

  # callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  def asset_file_paths
    self.mod_asset_files.joins(:asset_file).pluck(:subpath, :path).map { |item| item.join('') }
  end

  def update_lazy_counters
    self.asset_files_count = ModAssetFile.where(mod_id: self.id).count
    self.plugins_count = Plugin.where(mod_id: self.id).count
  end

  def compute_extra_metrics
    days_since_release = DateTime.now - self.released.to_date

    # compute extra nexus metrics
    nex = self.nexus_infos
    if nex.present? && Rails.application.config.scrape_nexus_statistics
      nex.endorsement_rate = (nex.endorsements / days_since_release) if days_since_release > 0
      nex.dl_rate = (nex.unique_downloads / days_since_release) if days_since_release > 0
      nex.udl_to_endorsements = (nex.unique_downloads / nex.endorsements) if nex.endorsements > 0
      nex.udl_to_posts = (nex.unique_downloads / nex.posts_count) if nex.posts_count > 0
      nex.tdl_to_udl = (nex.total_downloads / nex.unique_downloads) if nex.unique_downloads > 0
      nex.views_to_tdl = (nex.views / nex.total_downloads) if nex.total_downloads > 0
      nex.save!
    end
  end

  def compute_average_rating
    total = 0.0
    count = 0
    self.reviews.where(hidden: false, approved: true).each do |r|
      total += r.overall_rating
      count += 1
    end
    if count > 0
      self.average_rating = (total / count)
    else
      self.average_rating = 0
    end
  end

  def compute_reputation
    if self.reviews_count < 5 && Rails.application.config.scrape_nexus_statistics
      if self.nexus_infos.present?
        endorsement_reputation = 100.0 / (1.0 + Math::exp(-0.15 * (self.endorsement_rate - 25)))
        self.reputation = endorsement_reputation
      end
    else
      review_reputation = (self.average_rating / 100)**3 * (510.0 / (1 + Math::exp(-0.2 * (self.reviews_count - 10))) - 60)
      self.reputation = review_reputation
    end

    if self.status == :unstable
      self.reputation = self.reputation / 4
    elsif self.status == :outdated
      self.reputation = self.reputation / 2
    end
  end

  def update_metrics
    self.compute_extra_metrics
    self.compute_average_rating
    self.compute_reputation
    self.update_lazy_counters
    self.save!
  end

  def self.index_json(collection, sources)
    # Includes hash for mods index query
    include_hash = { :author_users => { :only => [:id, :username] } }
    include_hash[:nexus_infos] = {:except => [:mod_id]} if sources[:nexus]
    include_hash[:lover_infos] = {:except => [:mod_id]} if sources[:lab]
    include_hash[:workshop_infos] = {:except => [:mod_id]} if sources[:workshop]

    collection.as_json({
        :include => include_hash
    })
  end

  def self.home_json(collection)
    collection.as_json({
        :only => [:id, :name, :authors, :released],
        :include => {
            :primary_category => {:only => [:name]}
        },
        :methods => [:image]
    })
  end

  def edit_json
    self.as_json({
        :include => {
            :tags => {
                :except => [:game_id, :hidden, :mod_lists_count],
                :include => {
                    :submitter => {
                        :only => [:id, :username]
                    }
                }
            },
            :nexus_infos => {:only => [:id, :last_scraped]},
            :workshop_infos => {:only => [:id, :last_scraped]},
            :lover_infos => {:only => [:id, :last_scraped]},
            :custom_sources => {:except => [:mod_id]},
            :mod_authors => {
                :only => [:id, :role, :user_id],
                :include => {
                    :user => {
                        :only => [:username]
                    }
                }
            },
            :required_mods => {
                :only => [:id],
                :include => {
                    :required_mod => {
                        :only => [:id, :name]
                    }
                }
            },
            :config_files => {
                :except => [:game_id, :mod_id, :mod_lists_count]
            }
        },
        :methods => :image
    })
  end

  def show_json
    self.as_json({
        :except => [:disallow_contributors, :hidden],
        :include => {
            :tags => {
                :except => [:game_id, :hidden, :mod_lists_count],
                :include => {
                    :submitter => {
                        :only => [:id, :username]
                    }
                }
            },
            :nexus_infos => {:except => [:mod_id]},
            :workshop_infos => {:except => [:mod_id]},
            :lover_infos => {:except => [:mod_id]},
            :plugins => {:only => [:id, :filename]},
            :custom_sources => {:except => [:mod_id]},
            :mod_authors => {
                :only => [:id, :role, :user_id],
                :include => {
                    :user => {
                        :only => [:username]
                    }
                }
            },
            :required_mods => {
                :only => [],
                :include => {
                    :required_mod => {
                        :only => [:id, :name]
                    }
                }
            },
            :required_by => {
                :only => [],
                :include => {
                    :mod => {
                        :only => [:id, :name]
                    }
                }
            }
        },
        :methods => :image
    })
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:id, :name]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def decrement_counters
      self.submitter.update_counter(:submitted_mods_count, -1) if self.submitted_by.present?
    end

    def increment_counters
      self.submitter.update_counter(:submitted_mods_count, 1) if self.submitted_by.present?
    end
end

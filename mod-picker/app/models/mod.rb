class Mod < ActiveRecord::Base
  include Filterable, Sortable, Reportable, Imageable, RecordEnhancements, SourceHelpers, ScopeHelpers, Trackable

  # ATTRIBUTES
  enum status: [ :good, :outdated, :unstable ]
  attr_accessor :updated_by
  self.per_page = 100

  # EVENT TRACKING
  track :added, :hidden, :updated
  track_milestones :column => 'stars_count', :milestones => [10, 50, 100, 500, 1000, 5000, 10000, 50000, 100000, 500000]

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :author_users, to: [:hidden, :unhidden, *Event.milestones]
  subscribe :contribution_authors, to: [:updated]
  subscribe :user_stars, to: [:updated]

  # SCOPES
  include_scope :has_adult_content, :alias => 'include_adult'
  include_scope :is_official, :alias => 'include_official'
  include_scope :is_utility, :alias => 'include_utilities'
  value_scope :is_utility
  game_scope :parent => true
  search_scope :name, :aliases, :combine => true
  user_scope :author_users, :alias => 'mp_author'
  enum_scope :status
  date_scope :released, :updated
  range_scope :reputation, :tags_count
  range_scope :average_rating, :alias => 'rating'
  counter_scope :plugins_count, :asset_files_count, :required_mods_count, :required_by_count, :stars_count, :mod_lists_count, :reviews_count, :compatibility_notes_count, :install_order_notes_count, :load_order_notes_count, :corrections_count
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
  relational_division_scope :tags, :text, [
      { class_name: 'ModTag', join_on: :mod_id, joinable_on: :tag_id },
      { class_name: 'Tag', join_on: :id }
  ]

  # UNIQUE SCOPES
  scope :visible, -> { where(hidden: false) }
  scope :include_games, -> (bool) { where.not(primary_category_id: nil) if !bool }
  scope :compatibility, -> (mod_list_id) {
    mod_list = ModList.find(mod_list_id)
    where.not(id: mod_list.incompatible_mod_ids)
  }
  scope :sources, -> (sources) {
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
  scope :categories, -> (ids) { where("primary_category_id in (:ids) OR secondary_category_id in (:ids)", ids: ids) }
  scope :author, -> (hash) {
    author = hash[:value]
    sources = hash[:sources]
    where_clause = []

    results = where_clause.push("nexus_infos.authors like :author OR nexus_infos.uploaded_by like :author") if sources[:nexus]
    results = where_clause.push("lover_infos.uploaded_by like :author") if sources[:lab]
    results = where_clause.push("workshop_infos.uploaded_by like :author") if sources[:workshop]
    results = where_clause.push("mods.authors like :author") if sources[:other]

    where(where_clause.join(" OR "), author: author)
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
  has_many :corrections, :as => 'correctable', :dependent => :destroy
  has_many :reviews, :inverse_of => 'mod', :dependent => :destroy
  has_many :mod_stars, :inverse_of => 'mod', :dependent => :destroy
  has_many :user_stars, :class_name => 'User', :through => 'mod_stars', :source => 'user', :inverse_of => 'starred_mods'

  # tags
  has_many :mod_tags, :inverse_of => 'mod', :dependent => :destroy
  has_many :tags, :through => 'mod_tags', :inverse_of => 'mods'

  # mod list usage
  has_many :mod_list_mods, :inverse_of => 'mod', :dependent => :destroy
  has_many :mod_lists, :through => 'mod_list_mods', :inverse_of => 'mods'

  accepts_nested_attributes_for :mod_options
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

  # VALIDATIONS
  validates :game_id, :submitted_by, :name, :authors, :released, presence: true
  validates :name, :aliases, length: {maximum: 128}

  # callbacks
  before_save :set_dates
  after_create :increment_counters
  before_destroy :decrement_counters

  def asset_file_paths
    self.mod_asset_files.joins(:asset_file).pluck(:subpath, :path).map { |item| item.join('') }
  end

  def update_lazy_counters
    mod_option_ids = mod_options.ids
    self.asset_files_count = ModAssetFile.mod_options(mod_option_ids).count
    self.plugins_count = Plugin.mod_options(mod_option_ids).count
  end

  def compute_extra_metrics
    days_since_release = DateTime.now - self.released.to_date

    # compute extra nexus metrics
    nex = nexus_infos
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
    reviews.where(hidden: false, approved: true).each do |r|
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
    if reviews_count < 5 && Rails.application.config.scrape_nexus_statistics
      if nexus_infos.present?
        endorsement_reputation = 100.0 / (1.0 + Math::exp(-0.15 * (self.endorsement_rate - 25)))
        self.reputation = endorsement_reputation
      end
    else
      review_reputation = (average_rating / 100)**3 * (510.0 / (1 + Math::exp(-0.2 * (reviews_count - 10))) - 60)
      self.reputation = review_reputation
    end

    if status == :unstable
      self.reputation = self.reputation / 4
    elsif status == :outdated
      self.reputation = self.reputation / 2
    end
  end

  def update_metrics
    compute_extra_metrics
    compute_average_rating
    compute_reputation
    update_lazy_counters
    save!
  end

  # note associations
  def compatibility_notes
    CompatibilityNote.where('first_mod_id = :mod_id OR second_mod_id = :mod_id', mod_id: id)
  end

  def install_order_notes
    InstallOrderNote.where('first_mod_id = :mod_id OR second_mod_id = :mod_id', mod_id: id)
  end

  def load_order_notes
    LoadOrderNote.where('first_plugin_id in (:plugin_ids) OR second_plugin_id in (:plugin_ids)', plugin_ids: plugins.ids)
  end

  def contribution_authors
    User.contributors(self)
  end

  def links_text
    a = ["    - #{name}:"]
    space = " " * 8
    a.push("#{space}Nexus Mods: #{nexus_infos.url}") if nexus_infos
    a.push("#{space}Lover's Lab: #{lover_infos.url}") if lover_infos
    a.push("#{space}Steam Workshop: #{workshop_infos.url}") if workshop_infos
    custom_sources.each { |source| a.push("#{space}#{source.label}: #{source.url}") }
    a.join("\r\n") + "\r\n"
  end

  def self.index_json(collection, sources)
    # Includes hash for mods index query
    include_hash = { :author_users => { :only => [:id, :username] } }
    include_hash[:nexus_infos] = {:except => [:mod_id]} if sources[:nexus]
    include_hash[:lover_infos] = {:except => [:mod_id]} if sources[:lab]
    include_hash[:workshop_infos] = {:except => [:mod_id]} if sources[:workshop]

    collection.as_json({
        :except => [:game_id, :submitted_by, :edited_by, :disallow_contributors, :disable_reviews, :lock_tags],
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

  def notification_json_options(event_type)
    { :only => [:name] }
  end

  # TODO: trim down json for reports
  def reportable_json_options
    {
        :except => [:disallow_contributors, :hidden],
        :include => {
            :submitter => {
                :only => [:username]
            },
            :nexus_infos => {:except => [:mod_id]},
            :workshop_infos => {:except => [:mod_id]},
            :lover_infos => {:except => [:mod_id]},
            :custom_sources => {:except => [:mod_id]},
            :mod_authors => {
                :only => [:id, :role, :user_id],
                :include => {
                    :user => {
                        :only => [:username]
                    }
                }
            },
            :primary_category => {
                :only => [:name]
            },
            :secondary_category => {
                :only => [:name]
            }
        },
        :methods => :image
    }
  end

  def self.sortable_columns
    {
        :except => [:game_id, :submitted_by, :primary_category_id, :secondary_category_id],
        :include => {
            :primary_category => {
                :only => [:name]
            },
            :secondary_category => {
                :only => [:name]
            },
            :nexus_infos => {
                :except => [:game_id, :last_scraped, :mod_id, :mod_name]
            },
            :lover_infos => {
                :except => [:game_id, :last_scraped, :mod_id, :mod_name]
            },
            :workshop_infos => {
                :except => [:game_id, :last_scraped, :mod_id, :mod_name]
            }
        }
    }
  end

  private
    def set_dates
      self.submitted = DateTime.now if submitted.nil?
    end

    def decrement_counters
      submitter.update_counter(:submitted_mods_count, -1) if submitted_by.present?
    end

    def increment_counters
      submitter.update_counter(:submitted_mods_count, 1) if submitted_by.present?
    end
end

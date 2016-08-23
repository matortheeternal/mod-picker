class Mod < ActiveRecord::Base
  include Filterable, Sortable, Imageable, RecordEnhancements

  attr_writer :tag_names, :asset_paths, :plugin_dumps, :nexus_info_id, :lover_info_id, :workshop_info_id
  enum status: [ :good, :outdated, :unstable ]

  # BOOLEAN SCOPES (excludes content when false)
  scope :include_hidden, -> (bool) { where(hidden: false) if !bool  }
  scope :include_adult, -> (bool) { where(has_adult_content: false) if !bool }
  scope :include_official, -> (bool) { where(is_official: false) if !bool }
  scope :include_utilities, -> (bool) { where(is_utility: false) if !bool }
  scope :include_games, -> (bool) { where.not(primary_category_id: nil) if !bool }
  # GENERAL SCOPES
  scope :utility, -> (bool) { where(is_utility: bool) }
  scope :search, -> (search) { where("name like ? OR aliases like ?", "%#{search}%", "%#{search}%") }
  scope :game, -> (game_id) {
    game = Game.find(game_id)
    if game.parent_game_id.present?
      where(game_id: [game.id, game.parent_game_id])
    else
      where(game_id: game.id)
    end
  }
  scope :exclude, -> (excluded_mod_ids) { where.not(id: excluded_mod_ids) }
  scope :sources, -> (sources) {
    results = self.where(nil)
    whereClause = []

    # nexus mods
    if sources[:nexus]
      results = results.includes(:nexus_infos).references(:nexus_infos)
      whereClause.push("nexus_infos.id IS NOT NULL")
    end
    # lover's lab
    if sources[:lab]
      results = results.includes(:lover_infos).references(:lover_infos)
      whereClause.push("lover_infos.id IS NOT NULL")
    end
    # steam workshop
    if sources[:workshop]
      results = results.includes(:workshop_infos).references(:workshop_infos)
      whereClause.push("workshop_infos.id IS NOT NULL")
    end
    # other sources
    if sources[:other]
      results = results.includes(:custom_sources).references(:custom_sources)
      whereClause.push("custom_sources.id IS NOT NULL")
    end

    # require one selected source to be present
    results = results.where(whereClause.join(" OR "))
    results
  }
  scope :released, -> (range) { where(released: parseDate(range[:min])..parseDate(range[:max])) }
  scope :updated, -> (range) { where(updated: parseDate(range[:min])..parseDate(range[:max])) }
  scope :categories, -> (categories) { where("primary_category_id IN (?) OR secondary_category_id IN (?)", categories, categories) }
  scope :tags, -> (array) { joins(:tags).where(:tags => {text: array}).having("COUNT(DISTINCT tags.text) = ?", array.length) }
  # MOD PICKER SCOPES
  scope :stars, -> (range) { range_scope(range, :stars_count) }
  scope :reviews, -> (range) { range_scope(range, :reviews_count) }
  scope :rating, -> (range) { range_scope(range, :average_rating) }
  scope :reputation, -> (range) { range_scope(range, :reputation) }
  scope :compatibility_notes, -> (range) { range_scope(range, :compatibility_notes_count) }
  scope :install_order_notes, -> (range) { range_scope(range, :install_order_notes_count) }
  scope :load_order_notes, -> (range) { range_scope(range, :load_order_notes_count) }
  # SHARED SCOPES (ALL)
  scope :author, -> (hash) {
    author = hash[:value]
    sources = hash[:sources]

    results = self.where(nil)
    results = results.where("nexus_infos.authors like ? OR nexus_infos.uploaded_by like ?", author, author) if sources[:nexus]
    results = results.where("lover_infos.uploaded_by like ?", author) if sources[:lab]
    results = results.where("workshop_infos.uploaded_by like ?", author) if sources[:workshop]
    results = results.where("mods.authors like ?", author) if sources[:other]
    results
  }
  scope :mp_author, -> (username) { joins(:author_users).where(:users => {username: username}) }
  scope :views, -> (range) {
    sources = range[:sources]

    results = self.where(nil)
    results = results.where(:nexus_infos => {:views => range[:min]..range[:max]}) if sources[:nexus]
    results = results.where(:lover_infos => {:views => range[:min]..range[:max]}) if sources[:lab]
    results = results.where(:workshop_infos => {:views => range[:min]..range[:max]}) if sources[:workshop]
    results
  }
  # SHARED SCOPES (SOME)
  scope :downloads, -> (range) {
    sources = range[:sources]

    results = self.where(nil)
    results = results.where(:nexus_infos => {:downloads => range[:min]..range[:max]}) if sources[:nexus]
    results = results.where(:lover_infos => {:downloads => range[:min]..range[:max]}) if sources[:lab]
    results
  }
  scope :file_size, -> (range) {
    sources = range[:sources]

    results = self.where(nil)
    results = results.where(:lover_infos => {:file_size => range[:min]..range[:max]}) if sources[:lab]
    results = results.where(:workshop_infos => {:file_size => range[:min]..range[:max]}) if sources[:workshop]
    results
  }
  scope :posts, -> (range) {
    sources = range[:sources]

    results = self.where(nil)
    results = results.where(:nexus_infos => {:posts_count => range[:min]..range[:max]}) if sources[:nexus]
    results = results.where(:workshop_infos => {:comments_count => range[:min]..range[:max]}) if sources[:workshop]
    results
  }
  scope :videos, -> (range) {
    sources = range[:sources]

    results = self.where(nil)
    results = results.where(:nexus_infos => {:videos_count => range[:min]..range[:max]}) if sources[:nexus]
    results = results.where(:workshop_infos => {:videos_count => range[:min]..range[:max]}) if sources[:workshop]
    results
  }
  scope :images, -> (range) {
    sources = range[:sources]

    results = self.where(nil)
    results = results.where(:nexus_infos => {:images_count => range[:min]..range[:max]}) if sources[:nexus]
    results = results.where(:workshop_infos => {:images_count => range[:min]..range[:max]}) if sources[:workshop]
    results
  }
  scope :favorites, -> (range)  {
    sources = range[:sources]

    results = self.where(nil)
    results = results.where(:lover_infos => {:followers_count => range[:min]..range[:max]}) if sources[:lab]
    results = results.where(:workshop_infos => {:favorites => range[:min]..range[:max]}) if sources[:workshop]
    results
  }
  scope :discussions, -> (range) {
    sources = range[:sources]

    results = self.where(nil)
    results = results.where(:nexus_infos => {:discussions_count => range[:min]..range[:max]}) if sources[:nexus]
    results = results.where(:workshop_infos => {:discussions_count => range[:min]..range[:max]}) if sources[:workshop]
    results
  }
  # UNIQUE SCOPES
  scope :endorsements, -> (range) { range_scope(range, :endorsements, :nexus_infos) }
  scope :unique_downloads, -> (range) { range_scope(range, :unique_downloads, :nexus_infos) }
  scope :files, -> (range) { range_scope(range, :files_count, :nexus_infos) }
  scope :bugs, -> (range) { range_scope(range, :bugs_count, :nexus_infos) }
  scope :articles, -> (range) { range_scope(range, :articles_count, :nexus_infos) }
  scope :subscribers, -> (range) { range_scope(range, :subscribers, :workshop_infos) }

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

  # plugins associated with the mod
  has_many :plugins, :inverse_of => 'mod', :dependent => :destroy
  # assets associated with the mod
  has_many :mod_asset_files, :inverse_of => 'mod', :dependent => :destroy
  has_many :asset_files, :through => :mod_asset_files, :inverse_of => 'mods'

  # requirements associated with the mod
  has_many :required_mods, :class_name => 'ModRequirement', :inverse_of => 'mod', :dependent => :destroy
  has_many :required_by, :class_name => 'ModRequirement', :inverse_of => 'required_mod', :dependent => :destroy

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

  # Validations
  validates :game_id, :submitted_by, :name, :authors, :released, presence: true
  validates :name, :aliases, length: {maximum: 128}

  # callbacks
  after_create :increment_counters
  before_update :destroy_associations, :hide_contributions
  after_save :create_associations
  before_destroy :decrement_counters

  def update_lazy_counters
    self.asset_files_count = ModAssetFile.where(mod_id: self.id).count
    self.plugins_count = Plugin.where(mod_id: self.id).count
  end

  def destroy_associations
    # destroy associations as needed
    if @plugin_dumps || @asset_paths
      self.mod_asset_files.destroy_all
      self.plugins.destroy_all
    end
  end

  def hide_contributions
    if self.attribute_changed?(:hidden) && self.hidden
      # prepare some helper variables
      plugin_ids = self.plugins.ids
      cnote_ids = CompatibilityNote.where("first_mod_id = ? OR second_mod_id = ?", id, id).ids
      inote_ids = InstallOrderNote.where("first_mod_id = ? OR second_mod_id = ?", id, id).ids
      lnote_ids = LoadOrderNote.where("first_plugin_id in (?) OR second_plugin_id in (?)", plugin_ids, plugin_ids).ids

      # hide content
      Review.where(mod_id: self.id).update_all(:hidden => true)
      Correction.where(correctable_type: "Mod", correctable_id: self.id).update_all(:hidden => true)
      CompatibilityNote.where(id: cnote_ids).update_all(:hidden => true)
      InstallOrderNote.where(id: inote_ids).update_all(:hidden => true)
      LoadOrderNote.where(id: lnote_ids).update_all(:hidden => true)
      Correction.where(correctable_type: "CompatibilityNote", correctable_id: cnote_ids).update_all(:hidden => true)
      Correction.where(correctable_type: "InstallOrderNote", correctable_id: inote_ids).update_all(:hidden => true)
      Correction.where(correctable_type: "LoadOrderNote", correctable_id: lnote_ids).update_all(:hidden => true)
    elsif self.attribute_changed?(:disable_reviews) && self.disable_reviews
      Review.where(mod_id: self.id).update_all(:hidden => true)
    end
  end

  def swap_mod_list_mods_tools_counts
    tools_operator = self.is_utility ? "+" : "-"
    mods_operator = self.is_utility ? "-" : "+"
    mod_list_ids = self.mod_lists.ids
    ModList.where(id: mod_list_ids).update_all("tools_count = tools_count #{tools_operator} 1, mods_count = mods_count #{mods_operator} 1")
  end

  def create_tags
    if @tag_names
      @tag_names.each do |text|
        tag = Tag.find_by(text: text, game_id: self.game_id)

        # create tag if we couldn't find it
        if tag.nil?
          tag = Tag.create(text: text, game_id: self.game_id, submitted_by: self.submitted_by)
        end

        # associate tag with mod
        self.mod_tags.create(tag_id: tag.id, submitted_by: self.submitted_by)
      end
    end
  end

  def create_asset_files
    if @asset_paths
      basepaths = []
      @asset_paths.each do |path|
        # prioritize files over data folder matching
        split_paths = path.split(/(?<=\.bsa\\|\.esp|\.esm|Data\\)/)
        basepaths |= [split_paths[0]] if split_paths.length > 1
      end
      # sort by longest path first so nested paths are prioritized
      basepaths.sort { |a,b| b.length - a.length }

      @asset_paths.each do |path|
        basepath = basepaths.find { |basepath| path.start_with?(basepath) }
        if basepath.present?
          asset_file = AssetFile.find_or_create_by(game_id: self.game_id, path: path.sub(basepath, ''))
          self.mod_asset_files.create(asset_file_id: asset_file.id, subpath: basepath)
        else
          self.mod_asset_files.create(subpath: path)
        end
      end
    end
  end

  def create_plugins
    if @plugin_dumps
      @plugin_dumps.each do |dump|
        # create plugin from dump
        dump[:game_id] = self.game_id
        plugin = Plugin.find_by(filename: dump[:filename], crc_hash: dump[:crc_hash])
        if plugin.nil?
          plugin = self.plugins.create(dump)
        else
          plugin.mod_id = self.id
          plugin.save
        end
      end
    end
  end

  def asset_file_paths
    self.mod_asset_files.joins(:asset_file).pluck(:subpath, :path).map { |item| item.join('') }
  end

  def link_sources
    if @nexus_info_id
      @nexus_info = NexusInfo.find(@nexus_info_id)
      @nexus_info.mod_id = self.id
      @nexus_info.save!
    end
    if @lover_info_id
      @lover_info = LoverInfo.find(@lover_info_id)
      @lover_info.mod_id = self.id
      @lover_info.save!
    end
    if @workshop_info_id
      @workshop_info = WorkshopInfo.find(@workshop_info_id)
      @workshop_info.mod_id = self.id
      @workshop_info.save!
    end
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

  def create_associations
    self.create_tags
    self.create_asset_files
    self.create_plugins
    self.link_sources
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
            :author_users => {:only => [:id, :username]},
            :required_mods => {
                :only => [],
                :include => {
                    :required_mod => {
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

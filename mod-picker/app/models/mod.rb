class Mod < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements

  attr_writer :tag_names, :asset_paths, :plugin_dumps, :nexus_info_id, :lover_info_id, :workshop_info_id
  enum status: [ :good, :dangerous, :obsolete ]

  # GENERAL SCOPES
  scope :search, -> (search) { where("name like ? OR aliases like ?", "%#{search}%", "%#{search}%") }
  scope :game, -> (game) { where(game_id: game) }
  scope :sources, -> (sources) {
    results = self.where(nil)
    results = results.joins('LEFT OUTER JOIN nexus_infos ON nexus_infos.mod_id = mods.id') if sources[:nexus]
    results = results.joins('LEFT OUTER JOIN lover_infos ON lover_infos.mod_id = mods.id') if sources[:lab]
    results = results.joins('LEFT OUTER JOIN workshop_infos ON workshop_infos.mod_id = mods.id') if sources[:workshop]
    results
  }
  scope :released, -> (low, high) { where(released: parseDate(low)..parseDate(high)) }
  scope :updated, -> (low, high) { where(updated: parseDate(low)..parseDate(high)) }
  scope :adult, -> (bool) { where(has_adult_content: bool) }
  scope :utility, -> (bool) { where(is_utility: bool) }
  scope :author, -> (author) { where("nexus_infos.authors like ? OR nexus_infos.uploaded_by like ? OR lover_infos.uploaded_by like ? OR workshop_infos.uploaded_by like ?", author, author, author, author) }
  scope :categories, -> (categories) { where("primary_category_id IN (?) OR secondary_category_id IN (?)", categories, categories) }
  scope :tags, -> (array) { joins(:tags).where(:tags => {text: array}) }
  # MOD PICKER SCOPES
  scope :stars, -> (low, high) { where(stars_count: (low..high)) }
  scope :reviews, -> (low, high) { where(reviews_count: (low..high)) }
  scope :rating, -> (low, high) { where(average_rating: (low..high)) }
  scope :compatibility_notes, -> (low, high) { where(compatibility_notes_count: (low..high)) }
  scope :install_order_notes, -> (low, high) { where(install_order_notes_count: (low..high)) }
  scope :load_order_notes, -> (low, high) { where(load_order_notes_count: (low..high)) }
  # SHARED SCOPES (ALL)
  scope :views, -> (low, high) { where("nexus_infos.views BETWEEN ? and ? OR workshop_infos.views BETWEEN ? and ? OR lover_infos.views BETWEEN ? and ?", low, high, low, high, low, high)}
  # SHARED SCOPES (SOME)
  scope :downloads, -> (low, high) { where("nexus_infos.total_downloads BETWEEN ? and ? OR lover_infos.downloads BETWEEN ? and ?", low, high, low, high) }
  scope :file_size, -> (low, high) { where("lover_infos.file_size BETWEEN ? and ? OR workshop_infos.file_size BETWEEN ? and ?", low, high, low, high) }
  scope :posts, -> (low, high) { where("nexus_infos.posts_count BETWEEN ? and ? OR workshop_infos.comments_count BETWEEN ? and ?", low, high, low, high) }
  scope :videos, -> (low, high) { where("nexus_infos.videos_count BETWEEN ? and ? OR workshop_infos.videos_count BETWEEN ? and ?", low, high, low, high) }
  scope :images, -> (low, high) { where("nexus_infos.images_count BETWEEN ? and ? OR workshop_infos.images_count BETWEEN ? and ?", low, high, low, high) }
  scope :favorites, -> (low, high) { where("lover_infos.followers_count BETWEEN ? and ? OR workshop_infos.favorites BETWEEN ? and ?", low, high, low, high) }
  scope :discussions, -> (low, high) { where("nexus_infos.discussions_count BETWEEN ? and ? OR workshop_infos.discussions_count BETWEEN ? and ?", low, high, low, high) }
  # UNIQUE SCOPES
  scope :endorsements, -> (low, high) { where(:nexus_infos => { endorsements: low..high }) }
  scope :unique_downloads, -> (low, high) { where(:nexus_infos => { unique_downloads: low..high }) }
  scope :files, -> (low, high) { where(:nexus_infos => { files_count: low..high }) }
  scope :bugs, -> (low, high) { where(:nexus_infos => { bugs_count: low..high }) }
  scope :articles, -> (low, high) { where(:nexus_infos => { articles_count: low..high }) }
  scope :subscribers, -> (low, high) { where(:workshop_infos => { subscribers: low..high }) }

  belongs_to :game, :inverse_of => 'mods'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'submitted_mods'

  # categories the mod belongs to
  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'secondary_mods'

  # site statistics associated with the mod
  has_one :nexus_infos, :class_name => 'NexusInfo', :dependent => :nullify
  has_one :lover_infos, :class_name => 'LoverInfo', :dependent => :nullify
  has_one :workshop_infos, :class_name => 'WorkshopInfo', :dependent => :nullify

  # plugins associated with the mod
  has_many :plugins, :inverse_of => 'mod', :dependent => :destroy
  # assets associated with the mod
  has_many :mod_asset_files, :inverse_of => 'mod', :dependent => :destroy
  has_many :asset_files, :through => :mod_asset_files, :inverse_of => 'mods'

  # requirements associated with the mod
  has_many :required_mods, :class_name => 'ModRequirement', :inverse_of => 'mod', :dependent => :destroy
  has_many :required_by, :class_name => 'ModRequirement', :inverse_of => 'required_mod', :dependent => :destroy
  
  # users who can edit the mod
  has_many :mod_authors, :inverse_of => 'mod', :dependent => :destroy
  has_many :authors, :through => 'mod_authors', :inverse_of => 'mods'

  # community feedback on the mod
  has_many :reviews, :inverse_of => 'mod', :dependent => :destroy
  has_many :mod_stars, :inverse_of => 'mod', :dependent => :destroy
  has_many :user_stars, :through => 'mod_stars', :class_name => 'User', :inverse_of => 'starred_mods'

  # tags
  has_many :mod_tags, :inverse_of => 'mod', :dependent => :destroy
  has_many :tags, :through => 'mod_tags', :inverse_of => 'mods'

  # compatibility notes
  has_many :first_compatibility_notes, :foreign_key => 'first_mod_id', :class_name => 'CompatibilityNote', :inverse_of => 'first_mod'
  has_many :second_compatibility_notes, :foreign_key => 'second_mod_id', :class_name => 'CompatibilityNote', :inverse_of => 'second_mod'

  # install order notes
  has_many :first_install_order_notes, :foreign_key => 'first_mod_id', :class_name => 'InstallOrderNote', :inverse_of => 'first_mod'
  has_many :second_install_order_notes, :foreign_key => 'second_mod_id', :class_name => 'InstallOrderNote', :inverse_of => 'second_mod'

  # load order notes
  has_many :first_load_order_notes, :through => 'plugins', :class_name => 'LoadOrderNote', :inverse_of => 'first_mod'
  has_many :second_load_order_notes, :through => 'plugins', :class_name => 'LoadOrderNote', :inverse_of => 'second_mod'

  # mod list usage
  has_many :mod_list_mods, :inverse_of => 'mod', :dependent => :destroy
  has_many :mod_lists, :through => 'mod_list_mods', :inverse_of => 'mods'

  accepts_nested_attributes_for :required_mods

  self.per_page = 100

  # Validations
  validates :name, :status, :game_id, :primary_category_id, presence: true
  validates :name, :aliases, length: {maximum: 128}

  # callbacks
  after_create :create_associations, :increment_counters
  before_destroy :decrement_counters

  def no_author?
    self.mod_authors.count == 0
  end

  def update_lazy_counters
    self.asset_files_count = ModAssetFile.where(mod_id: self.id).count
    self.plugins_count = Plugin.where(mod_id: self.id).count
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
      @asset_paths.each do |path|
        asset_file = AssetFile.find_or_create_by(game_id: self.game_id, filepath: path)
        self.mod_asset_files.create(asset_file_id: asset_file.id)
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
        end
      end
    end
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
    self.reviews.each do |r|
      total += r.overall_rating
      count += 1
    end
    self.average_rating = (total / count) if count > 0
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
  end

  def create_associations
    self.create_tags
    self.create_asset_files
    self.create_plugins
    self.link_sources
    self.compute_extra_metrics
    self.compute_average_rating
    self.compute_reputation
    self.save!
  end

  def compatibility_notes
    CompatibilityNote.where('first_mod_id = ? OR second_mod_id = ?', self.id, self.id)
  end

  def install_order_notes
    InstallOrderNote.where('first_mod_id = ? OR second_mod_id = ?', self.id, self.id)
  end

  def load_order_notes
    LoadOrderNote.where('first_plugin_id in ? OR second_plugin_id in ?', self.plugins.ids, self.plugins.ids)
  end

  def image
    png_path = File.join(Rails.public_path, "mods/#{id}.png")
    jpg_path = File.join(Rails.public_path, "mods/#{id}.jpg")
    if File.exists?(png_path)
      "/mods/#{id}.png"
    elsif File.exists?(jpg_path)
      "/mods/#{id}.jpg"
    else
      '/mods/Default.png'
    end
  end

  def show_json
    self.as_json({
      :include => {
          :tags => {
              :except => [:game_id, :hidden, :mod_lists_count],
              :include => {
                  :user => {
                      :only => [:id, :username]
                  }
              }
          },
          :nexus_infos => {:except => [:mod_id]},
          :workshop_infos => {:except => [:mod_id]},
          :lover_infos => {:except => [:mod_id]},
          :authors => {:only => [:id, :username]}
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
      self.user.update_counter(:submitted_mods_count, -1)
    end

    def increment_counters
      self.user.update_counter(:submitted_mods_count, 1)
    end
end

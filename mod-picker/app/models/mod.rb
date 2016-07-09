class Mod < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements

  attr_writer :tag_names, :asset_paths, :plugin_dumps, :nexus_info_id, :lover_info_id, :workshop_info_id, :image_file
  enum status: [ :good, :outdated, :unstable ]

  # BOOLEAN SCOPES (excludes content when false)
  scope :hidden, -> (bool) { where(hidden: false) if !bool  }
  scope :adult, -> (bool) { where(has_adult_content: false) if !bool }
  scope :official, -> (bool) { where(is_official: false) if !bool }
  scope :utility, -> (bool) { where(is_utility: false) if !bool }
  scope :is_game, -> (bool) { where.not(primary_category_id: nil) if !bool }
  # GENERAL SCOPES
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
  scope :stars, -> (range) { where(stars_count: (range[:min]..range[:max])) }
  scope :reviews, -> (range) { where(reviews_count: (range[:min]..range[:max])) }
  scope :rating, -> (range) { where(average_rating: (range[:min]..range[:max])) }
  scope :reputation, -> (range) { where(reputation: (range[:min]..range[:max])) }
  scope :compatibility_notes, -> (range) { where(compatibility_notes_count: (range[:min]..range[:max])) }
  scope :install_order_notes, -> (range) { where(install_order_notes_count: (range[:min]..range[:max])) }
  scope :load_order_notes, -> (range) { where(load_order_notes_count: (range[:min]..range[:max])) }
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
  scope :endorsements, -> (range) { where(:nexus_infos => { endorsements: range[:min]..range[:max] }) }
  scope :unique_downloads, -> (range) { where(:nexus_infos => { unique_downloads: range[:min]..range[:max] }) }
  scope :files, -> (range) { where(:nexus_infos => { files_count: range[:min]..range[:max] }) }
  scope :bugs, -> (range) { where(:nexus_infos => { bugs_count: range[:min]..range[:max] }) }
  scope :articles, -> (range) { where(:nexus_infos => { articles_count: range[:min]..range[:max] }) }
  scope :subscribers, -> (range) { where(:workshop_infos => { subscribers: range[:min]..range[:max] }) }

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
  after_save :create_associations, :save_image
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
        else
          plugin.mod_id = self.id
          plugin.save
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
  end

  def delete_old_mod_images
    png_path = Rails.root.join('public', 'mods', self.id.to_s + '.png')
    jpg_path = Rails.root.join('public', 'mods', self.id.to_s + '.jpg')

    if File.exist?(png_path)
      File.delete(png_path)
    end
    if File.exist?(jpg_path)
      File.delete(jpg_path)
    end
  end

  def save_image
    if @image_file
      ext = File.extname(@image_file.original_filename)
      local_filename = Rails.root.join('public', 'mods', self.id.to_s + ext)
      if ext != '.png' && ext != '.jpg' # image must be png or jpg
        self.errors.add(:image, 'Invalid image type, must be PNG or JPG')
      elsif @image_file.size > 1048576 # 1 megabyte max file size
        self.errors.add(:image, 'Image is too big')
      else
        begin
          delete_old_mod_images
          File.open(local_filename, 'wb') do |f|
            f.write(@image_file.read)
          end
        rescue
          self.errors.add(:image, 'Unknown failure')
        end
      end
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

  def compatibility_notes
    CompatibilityNote.where('first_mod_id = ? OR second_mod_id = ?', self.id, self.id)
  end

  def install_order_notes
    InstallOrderNote.where('first_mod_id = ? OR second_mod_id = ?', self.id, self.id)
  end

  def load_order_notes
    LoadOrderNote.where('first_plugin_id in (?) OR second_plugin_id in (?)', self.plugins.ids, self.plugins.ids)
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
           }
       },
       :methods => :image
    })
  end

  def show_json
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

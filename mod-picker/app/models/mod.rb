class Mod < ActiveRecord::Base
  include Filterable, Sortable

  scope :search, -> (search) { where("name like ? OR aliases like ?", "%#{search}%", "%#{search}%") }
  scope :author, -> (author) { joins(:nexus_infos).where("nexus_infos.authors like ? OR nexus_infos.uploaded_by like ?", "#{author}", "#{author}") }
  scope :adult, -> (adult) { where(has_adult_content: adult) }
  scope :game, -> (game) { where(game_id: game) }
  scope :categories, -> (categories) { where("primary_category_id IN (?) OR secondary_category_id IN (?)", categories, categories) }
  scope :stars, -> (low, high) { where(mod_stars_count: (low..high)) }
  scope :reviews, -> (low, high) { where(reviews_count: (low..high)) }
  scope :cnotes, -> (low, high) { where(compatibility_notes_count: (low..high)) }
  scope :ionotes, -> (low, high) { where(install_order_notes_count: (low..high)) }
  scope :lonotes, -> (low, high) { where(load_order_notes_count: (low..high)) }
  scope :versions, -> (low, high) { where(mod_versions_count: (low..high)) }
  scope :released, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {date_added: (parseDate(low)..parseDate(high))}) }
  scope :updated, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {date_updated: (parseDate(low)..parseDate(high))}) }
  scope :endorsements, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {endorsements: (low..high)} ) }
  scope :tdl, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {total_downloads: (low..high)} ) }
  scope :udl, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {unique_downloads: (low..high)} ) }
  scope :views, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {views: (low..high)} ) }
  scope :posts, -> (low, high) { joins(:nexus_infos).where(:nexus_infos=> {posts_count: (low..high)} ) }
  scope :videos, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {videos_count: (low..high)} ) }
  scope :images, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {images_count: (low..high)} ) }
  scope :files, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {files_count: (low..high)} ) }
  scope :articles, -> (low, high) { joins(:nexus_infos).where(:nexus_infos => {articles_count: (low..high)} ) }
  scope :tags, -> (array) { joins(:tags).where(:tags => {text: array}) }

  enum status: [ :good, :dangerous, :obsolete ]

  belongs_to :game, :inverse_of => 'mods'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'submitted_mods'

  # categories the mod belongs to
  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'secondary_mods'

  # site statistics associated with the mod
  has_one :nexus_infos, :class_name => 'NexusInfo'
  has_one :lover_infos, :class_name => 'NexusInfo'
  has_one :workshop_infos, :class_name => 'NexusInfo'
  
  # users who can edit the mod
  has_many :mod_authors, :inverse_of => 'mod'
  has_many :authors, :through => 'mod_authors', :inverse_of => 'mods'

  # community feedback on the mod
  has_many :reviews, :inverse_of => 'mod'
  has_many :mod_stars, :inverse_of => 'mod'
  has_many :user_stars, :through => 'mod_stars', :class_name => 'User', :inverse_of => 'starred_mods'

  # tags
  has_many :mod_tags, :inverse_of => 'mod'
  has_many :tags, :through => 'mod_tags', :inverse_of => 'mods'

  # install order notes
  has_many :install_before_notes, :foreign_key => 'install_first', :class_name => 'InstallOrderNote', :inverse_of => 'install_first_mod'
  has_many :install_after_notes, :foreign_key => 'install_second', :class_name => 'InstallOrderNote', :inverse_of => 'install_second_mod'

  # mod versions and associated data
  has_many :mod_versions, :inverse_of => 'mod'

  # mod list usage
  has_many :mod_list_mods, :inverse_of => 'mod'
  has_many :mod_lists, :through => 'mod_list_mods', :inverse_of => 'mods'

  self.per_page = 5

  accepts_nested_attributes_for :mod_versions

  def no_author?
    self.mod_authors.count == 0
  end

  def create_tags(tags)
    tags.each do |text|
      tag = Tag.find_by(text: text, game_id: self.game_id)
      # create tag if we couldn't find it
      if tag.nil?
        tag = Tag.create(text: text, game_id: self.game_id, submitted_by: self.submitted_by)
      end

      # associate tag with mod
      self.mod_tags.create(tag_id: tag.id, submitted_by: self.submitted_by)
    end
  end

  def create_asset_files(asset_file_tree, mod_version_id=nil)
    asset_file_tree.each do |path|
      asset_file = ModAssetFile.find_or_create_by(filepath: path)

      # find mod version to associate asset files with
      if mod_version_id.present?
        mv = self.mod_versions.find_by(mod_version_id)
      else
        mv = self.mod_versions.first
      end

      # associate asset files with mod version
      mv.mod_version_files.create(mod_asset_file_id: asset_file.id)
    end
  end

  def compute_extra_metrics
    days_since_release = DateTime.now - self.released.to_date

    # compute extra nexus metrics
    nex = self.nexus_infos
    if nex.present?
      nex.endorsement_rate = (nex.endorsements / days_since_release) if days_since_release != 0
      nex.dl_rate = (nex.unique_downloads / days_since_release) if days_since_release != 0
      nex.udl_to_endorsements = (nex.unique_downloads / nex.endorsements) if nex.endorsements != 0
      nex.udl_to_posts = (nex.unique_downloads / nex.posts_count) if nex.posts_count != 0
      nex.tdl_to_udl = (nex.total_downloads / nex.unique_downloads) if nex.unique_downloads != 0
      nex.views_to_tdl = (nex.views / nex.total_downloads) if nex.total_downloads != 0
      nex.save!
    end

    # compute update rate
    self.update_rate = days_since_release / self.mod_versions_count
  end

  def compute_average_rating
    total = 0
    count = 0
    self.reviews.each do |r|
      total += r.overall_rating
      count += 1
    end
    self.average_rating = total.to_f / count
  end

  def compute_reputation
    if self.reviews_count < 5
      if self.nexus_infos.present?
        endorsement_reputation = 100.0 / (1.0 + Math::exp(-0.15 * (self.endorsement_rate - 25)))
        self.reputation = endorsement_reputation
      end
    else
      compute_average_rating
      review_reputation = (self.average_rating / 10.0)^3 * (510.0 / (1 + Math::exp(-0.2 * (self.review_count - 10))) - 60)
      self.reputation = review_reputation
    end
  end

  def show_json
    self.as_json(:include => {
        :mod_versions => {
            :except => [:mod_id],
            :methods => :required_mods
        },
        :reviews => {
            :except => [:submitted_by],
            :include => {
                :user => {
                    :only => [:id, :username, :role, :title],
                    :include => {
                        :reputation => {:only => [:overall]}
                    },
                    :methods => :avatar
                }
            }
        },
        :tags => {
            :except => [:game_id, :hidden, :mod_lists_count],
            :user => {
                :only => [:id, :username]
            }
        }
    })
  end

  def as_json(options={})
    default_options = {
        :include => {
            :nexus_infos => {:except => [:mod_id, :changelog]},
            :authors => {:only => [:id, :username]}
        }
    }
    options[:include] ||= {}
    options[:include] = default_options[:include].merge(options[:include])
    super(options)
  end
end

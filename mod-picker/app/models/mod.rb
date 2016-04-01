class Mod < ActiveRecord::Base
  include Filterable

  scope :search, -> (search) { where("name like ? OR aliases like ?", "%#{search}%", "%#{search}%") }
  scope :adult, -> (adult) { where(has_adult_content: adult) }
  scope :game, -> (game) { where(game_id: game) }
  scope :category, -> (category) { where("primary_category_id=? OR secondary_category_id=?", "#{category}%", "#{category}%") }
  scope :stars, -> (low, high) { where(user_stars_count: (low..high)) }
  scope :reviews, -> (low, high) { where(reviews_count: (low..high)) }
  scope :versions, -> (low, high) { where(mod_versions_count: (low..high)) }
  scope :released, -> (low, high) { where(:nexus_infos => {date_released: (low..high)}) }
  scope :updated, -> (low, high) { where(:nexus_infos => {date_updated: (low..high)} ) }
  scope :endorsements, -> (low, high) { where(:nexus_infos => {endorsements: (low..high)} ) }
  scope :tdl, -> (low, high) { where(:nexus_infos => {total_downloads: (low..high)} ) }
  scope :udl, -> (low, high) { where(:nexus_infos => {unique_downloads: (low..high)} ) }
  scope :views, -> (low, high) { where(:nexus_infos => {views: (low..high)} ) }
  scope :posts, -> (low, high) { where(:nexus_infos => {posts_count: (low..high)} ) }
  scope :videos, -> (low, high) { where(:nexus_infos => {videos_count: (low..high)} ) }
  scope :images, -> (low, high) { where(:nexus_infos => {images_count: (low..high)} ) }
  scope :files, -> (low, high) { where(:nexus_infos => {files_count: (low..high)} ) }
  scope :articles, -> (low, high) { where(:nexus_infos => {articles_count: (low..high)} ) }

  belongs_to :game, :inverse_of => 'mods'

  # categories the mod belongs to
  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'secondary_mods'

  # site statistics associated with the mod
  has_one :nexus_info
  has_one :lover_info
  has_one :workshop_info

  # users who can edit the mod
  has_many :mod_authors, :inverse_of => 'mod'
  has_many :authors, :through => 'mod_authors', :inverse_of => 'mods'

  # community feedback on the mod
  has_many :reviews, :inverse_of => 'mod', :counter_cache => true
  has_many :mod_stars, :inverse_of => 'starred_mod'
  has_many :user_stars, :through => 'mod_stars', :inverse_of => 'starred_mods', :counter_cache => true

  # install order notes
  has_many :install_before_notes, :foreign_key => 'install_first', :class_name => 'InstallOrderNote', :inverse_of => 'install_first_mod'
  has_many :install_after_notes, :foreign_key => 'install_second', :class_name => 'InstallOrderNote', :inverse_of => 'install_second_mod'

  # mod versions
  has_many :mod_versions, :inverse_of => 'mod', :counter_cache => true

  accepts_nested_attributes_for :mod_versions

  def no_author?
    self.mod_authors.count == 0
  end

  def update_compatibility_notes_count
    self.compatibility_notes_count = self.mod_versions.compatibility_notes.count
  end

  def update_install_order_notes_count
    self.install_order_notes_count = self.install_before_notes.count + self.install_after_notes.count
  end

  def update_load_order_notes_count
    self.load_order_notes_count = (self.mod_versions.plugins.load_before_notes + self.mod_versions.plugins.load_after_notes).count
  end

  def as_json(options={})
    super(:include => {
        :nexus_info => {:except => [:mod_id, :changelog]},
        :mod_versions => {:except => [:mod_id]},
        :authors => {:only => [:id, :username]},
        :reviews => {:except => [:mod_id, :id]}
    })
  end
end

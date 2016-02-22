class Mod < ActiveRecord::Base
  include Filterable

  scope :search, -> (search) { where("name like ? OR aliases like ?", "#{search}%", "#{search}%") }
  scope :adult, -> (adult) { where(has_adult_content: adult) }
  scope :game, -> (game) { where(game_id: game) }
  scope :category, -> (category) { where("primary_category_id=? OR secondary_category_id=?", "#{category}%", "#{category}%") }
  scope :stars, -> (low, high) { where(user_stars_count: (low..high)) }
  scope :reviews, -> (low, high) { where(reviews_count: (low..high)) }
  scope :comments, -> (low, high) { where(comments_count: (low..high)) }
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

  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'secondary_mods'

  has_one :nexus_info
  has_one :lover_info
  has_one :workshop_info

  has_many :mod_versions, :inverse_of => 'mod', :counter_cache => true

  has_many :mod_stars, :inverse_of => 'starred_mod'
  has_many :user_stars, :through => 'mod_stars', :inverse_of => 'starred_mods', :counter_cache => true

  has_many :mod_authors, :inverse_of => 'mod'
  has_many :authors, :through => 'mod_authors', :inverse_of => 'mods'

  has_many :reviews, :inverse_of => 'mod', :counter_cache => true
  has_many :comments, :as => 'commentable', :counter_cache => true

  def as_json(options={})
    super(:include => {
        :nexus_info => {:except => [:mod_id, :changelog]},
        :mod_versions => {:except => [:mod_id]},
        :authors => {:only => [:id, :username]},
        :reviews => {:except => [:mod_id, :id]}
    })
  end
end

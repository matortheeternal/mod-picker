class Mod < ActiveRecord::Base
  include Filterable
  
  scope :search, -> (search) { where("name like ? OR aliases like ?", "#{search}%", "#{search}") }
  scope :adult, -> (adult) { where has_adult_content: adult }
  scope :game, -> (game) { where game_id: game }
  scope :category, -> (category) { where("primary_category_id=? OR secondary_category_id=?", category, category) }
  scope :stars, -> (stars) { where(user_stars_count: stars) }
  scope :reviews, -> (reviews) { where(reviews_count: reviews) }
  scope :comments, -> (comments) { where(comments_count: comments) }
  scope :versions, -> (versions) { where(mod_versions_count: versions) }
  scope :released, -> (released) { where(:nexus_infos => {date_released: released} ) }
  scope :updated, -> (updated) { where(:nexus_infos => {date_updated: updated} ) }
  scope :endorsements, -> (endorsements) { where(:nexus_infos => {endorsements: endorsements} ) }
  scope :tdl, -> (tdl) { where(:nexus_infos => {total_downloads: tdl} ) }
  scope :udl, -> (udl) { where(:nexus_infos => {unique_downloads: udl} ) }
  scope :views, -> (views) { where(:nexus_infos => {views: views} ) }
  scope :posts, -> (posts) { where(:nexus_infos => {posts_count: posts} ) }
  scope :videos, -> (videos) { where(:nexus_infos => {videos_count: videos} ) }
  scope :images, -> (images) { where(:nexus_infos => {images_count: images} ) }
  scope :files, -> (files) { where(:nexus_infos => {files_count: files} ) }
  scope :articles, -> (articles) { where(:nexus_infos => {articles_count: articles} ) }

  belongs_to :game, :inverse_of => 'mods'

  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'secondary_mods'

  has_one :nexus_info
  has_one :lover_info
  has_one :workshop_info

  has_many :mod_versions, :inverse_of => 'mod'

  has_many :mod_stars, :inverse_of => 'starred_mod'
  has_many :user_stars, :through => 'mod_stars', :inverse_of => 'starred_mods'

  has_many :mod_authors, :inverse_of => 'mod'
  has_many :authors, :through => 'mod_authors', :inverse_of => 'mods'

  has_many :reviews, :inverse_of => 'mod'
  has_many :comments, :as => 'commentable'

  def as_json(options={})
    super(:include => {
        :nexus_info => {:except => [:mod_id, :changelog]},
        :mod_versions => {:except => [:mod_id]},
        :authors => {:only => [:id, :username]},
        :reviews => {:except => :id}
    })
  end
end

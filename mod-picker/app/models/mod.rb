class Mod < ActiveRecord::Base
  include Filterable
  
  scope :search, -> (name) { where("name like ?", "#{search}%").or("aliases like ?", "#{search}") }
  scope :adult, -> (has_adult_content) { where has_adult_content: adult }
  scope :game, -> (game_id) { where game_id: game }
  scope :category, -> { where(primary_category_id: category).or(secondary_category_id: category) }
  scope :stars, -> { where(user_stars_count: stars) }
  scope :reviews, -> { where(reviews_count: reviews) }
  scope :comments, -> { where(comments_count: comments) }
  scope :versions, -> { where(mod_versions_count: versions) }
  scope :released, -> { where(nexus_info.date_released: released) }
  scope :updated, -> { where(nexus_info.date_updated: updated) }
  scope :endorsements, -> { where(nexus_info.endorsements: endorsements) }
  scope :tdl, -> { where(nexus_info.total_downloads: tdl) }
  scope :udl, -> { where(nexus_info.unique_downloads: udl) }
  scope :views, -> { where(nexus_info.views: views) }
  scope :posts, -> { where(nexus_info.posts: posts) }
  scope :videos, -> { where(nexus_info.videos: videos) }
  scope :images, -> { where(nexus_info.images: images) }
  scope :files, -> { where(nexus_info.files: files) }
  scope :articles, -> { where(nexus_info.articles: articles) }

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

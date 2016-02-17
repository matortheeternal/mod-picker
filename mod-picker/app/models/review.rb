class Review < ActiveRecord::Base
  include Filterable

  scope :mod, -> (mod) { where(mod_id: mod) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  belongs_to :mod, :inverse_of => 'reviews', :counter_cache => true
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'
end

class Review < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  belongs_to :mod, :inverse_of => 'reviews'
  has_many :incorrect_notes, :as => 'correctable'
  has_many :helpful_marks, :as => 'helpfulable'
end

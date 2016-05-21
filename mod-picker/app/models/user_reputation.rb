class UserReputation < ActiveRecord::Base
  include Filterable, CounterCacheEnhancements

  scope :user, -> (id) { where(user_id: id) }

  belongs_to :user

  has_many :from_links, :class_name => 'ReputationLink', :inverse_of => 'from_rep'
  has_many :to_links, :class_name => 'ReputationLink', :inverse_of => 'to_rep'
  
  # Validations
  validates :user_id, :overall, :offset, presence: true
end

class UserReputation < ActiveRecord::Base
  include Filterable, RecordEnhancements

  scope :user, -> (id) { where(user_id: id) }

  belongs_to :user

  has_many :from_links, :class_name => 'ReputationLink', :inverse_of => 'to_rep', :dependent => :destroy
  has_many :to_links, :class_name => 'ReputationLink', :inverse_of => 'from_rep', :dependent => :destroy

  # Validations
  validates :user_id, presence: true
end

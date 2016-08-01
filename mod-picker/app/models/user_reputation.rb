class UserReputation < ActiveRecord::Base
  include Filterable, RecordEnhancements

  scope :user, -> (id) { where(user_id: id) }

  belongs_to :user

  has_many :received_reputation, :class_name => 'ReputationLink', :inverse_of => 'to_rep', :dependent => :destroy
  has_many :given_reputation, :class_name => 'ReputationLink', :inverse_of => 'from_rep', :dependent => :destroy

  # Validations
  validates :user_id, presence: true
end

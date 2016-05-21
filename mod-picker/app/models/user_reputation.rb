class UserReputation < EnhancedRecord::Base
  include Filterable

  before_validation :init

  belongs_to :user

  scope :user, -> (id) { where(user_id: id) }
  has_many :from_links, :class_name => 'ReputationLink', :inverse_of => 'from_rep'
  has_many :to_links, :class_name => 'ReputationLink', :inverse_of => 'to_rep'
  
  # Validations
  validates :user_id, :overall, :offset, presence: true

  def init
    self.overall ||= 5.0
    self.offset ||= 5.0
    self.site_rep ||= 0.0
    self.contribution_rep ||= 0.0
    self.author_rep ||= 0.0
    self.given_rep ||= 0.0
    self.dont_compute ||= false
    self.last_computed ||= DateTime.now
  end
end

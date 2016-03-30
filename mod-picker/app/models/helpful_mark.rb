class HelpfulMark < ActiveRecord::Base
  include Filterable

  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :helpfulable, :polymorphic => true
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'helpful_marks'

  # Validation
  # :helpful's presence is not required because it will fail if :helpful == false
  validates :helpfulable_id, :helpfulable_type, presence: true

  validates :helpful, inclusion: {in: [true, false], 
                                  message: "must be true or false"}

  after_initialize :init

  def init
    self.submitted ||= Date.today
  end                                  
end

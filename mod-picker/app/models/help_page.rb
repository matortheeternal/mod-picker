class HelpPage < ActiveRecord::Base
  after_initialize :init

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'help_pages'

  # validations
  validates :name, :text_body, presence: true
  validates :name, length: {in: 4..128}
  validates :text_body, length: {in: 64..32768}

  def init
    self.submitted ||= DateTime.now
  end
end

module Approveable
  extend ActiveSupport::Concern

  included do
    before_create :auto_approve
  end

  def auto_approve
    self.approved = submitter.has_auto_approval?
    true
  end
end
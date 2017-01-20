module Approveable
  extend ActiveSupport::Concern

  included do
    before_create :auto_approve

    class_attribute :approval_method
    self.approval_method = :has_auto_approval?
  end

  def auto_approve
    self.approved = submitter.public_send(self.approval_method)
    true
  end

  module ClassMethods
    def unapproved_count
      search = { approved: false }
      search[:hidden] = false if respond_to?(:hidden)
      where(search).count
    end
  end
end
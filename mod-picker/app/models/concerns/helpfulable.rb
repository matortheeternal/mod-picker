module Helpfulable
  extend ActiveSupport::Concern

  included do
    has_many :helpful_marks, :as => 'helpfulable'
  end

  def recompute_helpful_counts
    self.helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "InstallOrderNote", helpful: true).count
    self.not_helpful_count = HelpfulMark.where(helpfulable_id: self.id, helpfulable_type: "InstallOrderNote", helpful: false).count
  end
end
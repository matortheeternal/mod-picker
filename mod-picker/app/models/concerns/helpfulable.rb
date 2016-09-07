module Helpfulable
  extend ActiveSupport::Concern

  included do
    range_scope :reputation, :helpful_count, :not_helpful_count

    has_many :helpful_marks, :as => 'helpfulable'
  end

  def recompute_helpful_counts
    self.helpful_count = helpful_marks.helpful(true).count
    self.not_helpful_count = helpful_marks.helpful(false).count
  end

  def compute_reputation
    if respond_to?(:standing)
      if standing == :bad
        self.helpfulness = -100
        return
      elsif standing == :unknown
        self.helpfulness = 0
        return
      end
    end

    user_rep = submitter.reputation.overall
    helpfulness = (helpful_count - not_helpful_count)

    # calculate reputation of contribution based on user reputation and helpfulness
    if user_rep < 0
      self.reputation = user_rep + helpfulness
    else
      user_rep_factor = 2 / (1 + Math::exp(-0.0075 * (user_rep - 640)))
      if helpful_count < not_helpful_count
        self.reputation = (1 - user_rep_factor / 2) * helpfulness
      else
        self.reputation = (1 + user_rep_factor / 2) * helpfulness
      end
    end
  end
end
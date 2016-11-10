module Helpfulable
  extend ActiveSupport::Concern

  included do
    range_scope :helpful_count, :not_helpful_count
    range_scope :reputation, :alias => 'helpfulness'

    has_many :helpful_marks, :as => 'helpfulable'
  end

  def user_rep
    submitter.reputation.overall
  end

  def helpfulness_score
    [-20, helpful_count - not_helpful_count, 20].sort[1]
  end

  def user_rep_factor
    factor = 1 / (1 + Math::exp(-0.0075 * (user_rep - 640)))
    helpful_count < not_helpful_count ? 1 - factor : 1 + factor
  end

  def compute_reputation
    if user_rep < 0
      self.reputation = user_rep + helpfulness_score
    else
      self.reputation = user_rep_factor * helpfulness_score
    end
  end

  def compute_reputation!
    compute_reputation
    update_column(:reputation, self.reputation)
  end
end
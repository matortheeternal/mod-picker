module Reputable
  extend ActiveSupport::Concern

  def compute_reputation
    # TODO: We could base this off of the reputation of the people who marked the review helpful/not helpful, but we aren't doing that yet
    user_rep = self.submitter.reputation.overall
    helpfulness = (self.helpful_count - self.not_helpful_count)

    # minimum helpfulness score is -20
    # maximum helpfulness score is +20
    helpfulness = -20 if helpfulness < -20
    helpfulness = 20 if helpfulness > 20

    # calculate reputation of contribution based on user reputation
    if user_rep < 0
      self.reputation = user_rep + helpfulness
    else
      user_rep_factor = 2 / (1 + Math::exp(-0.0075 * (user_rep - 640)))
      if self.helpful_count < self.not_helpful_count
        self.reputation = (1 - user_rep_factor / 2) * helpfulness
      else
        self.reputation = (1 + user_rep_factor / 2) * helpfulness
      end
    end
  end
end
class ReputationWorker
  include Sidekiq::Worker

  # CONSTANTS
  NUM_ITERATIONS = 4

  def update_reputation_network
    UserReputation.where(dont_compute: false).
      joins("JOIN (#{sum_subquery.to_sql}) g ON user_reputations.id = g.id").
      update_all("overall = offset + site_rep + contribution_rep + author_rep + g.sum, given_rep = g.sum")
  end

  def sum_subquery
    UserReputation.select("user_reputations.id,SUM(LR.overall * 0.05) AS sum").
      joins("JOIN reputation_links ON user_reputations.id = reputation_links.to_rep_id").
      joins("JOIN user_reputations LR ON reputation_links.from_rep_id = LR.id").
      where("LR.dont_compute = 0").
      group("user_reputations.id")
  end

  def perform
    Benchmark.bm do |benchmark|
      puts "\nCalculating base reputation"
      start_time = DateTime.now
      benchmark.report("B") {
        UserReputation.computable.find_each do |user_reputation|
          user_reputation.recompute(start_time)
        end
      }

      puts "\nCalculating network reputation"
      NUM_ITERATIONS.times do |iteration|
        benchmark.report("I#{iteration + 1}") {
          update_reputation_network
        }
      end
    end
  end
end
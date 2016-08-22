class ReputationWorker
  include Sidekiq::Worker

  NUM_ITERATIONS = 4

  # AREL METHODS
  def user_reputation_table
    @user_reputation_table ||= UserReputation.arel_table
  end

  def linked_reputations_table
    @linked_reputations_table ||= UserReputation.arel_table.alias('linked_reputations')
  end

  def reputation_links_table
    @reputation_links_table ||= ReputationLink.arel_table
  end

  def update_reputations_query
    manager.table(joined_table).
        where(subquery[:r_id].eq(user_reputation_table[:id])).
        where(user_reputation_table[:dont_compute].eq(false)).
        set([[user_reputation_table[:given_rep], subquery[:sum]]])
  end

  def joined_table
    Arel::Nodes::JoinSource.new(
        user_reputation_table,
        [user_reputation_table.create_join(subquery)]
    )
  end

  def manager
    Arel::UpdateManager.new(UserReputation)
  end

  def subquery
    user_reputation_table.project(
        user_reputation_table[:id].as('r_id'),
        Arel.sql("SUM(linked_reputations.overall * 0.05) AS sum")
    ).
        join(reputation_links_table).on(user_reputation_table[:id].eq(reputation_links_table[:to_rep_id])).
        join(linked_reputations_table).on(linked_reputations_table[:id].eq(reputation_links_table[:from_rep_id])).
        where(linked_reputations_table[:dont_compute].eq(false)).
        group(user_reputation_table[:id]).as('g')
  end

  def perform
    Benchmark.bm do |benchmark|
      puts "\nCalculating base reputation"
      benchmark.report("B") {
        UserReputation.computable.find_each do |user_reputation|
          user_reputation.calculate_site_rep!
          user_reputation.calculate_contribution_rep!
          user_reputation.calculate_author_rep!
          user_reputation.save!
        end
      }

      puts "\nCalculating network reputation"
      NUM_ITERATIONS.times do |iteration|
        benchmark.report("I#{iteration + 1}") {
          ActiveRecord::Base.connection.execute(update_reputations_query.to_sql)
        }
      end
    end
  end
end
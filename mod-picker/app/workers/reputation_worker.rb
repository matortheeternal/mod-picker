class ReputationWorker
  include Sidekiq::Worker

  # CONSTANTS
  NUM_ITERATIONS = 4
  USER_ENDORSE_RATIO = 0.05

  def calculate_given_rep(reputations)
    def iterate(reputations)
      @visited_rep_ids = {}

      def traverse_from(src_rep)
        @visited_rep_ids[src_rep.id] = true
        src_rep.given_reputation.each do |dst_rep|
          next if dst_rep.dont_compute
          dst_rep.given_rep += src_rep.overall_rep * USER_ENDORSE_RATIO
          unless @visited_rep_ids[dst_rep.id]
            traverse_from(dst_rep)
          end
        end
      end

      # traverse each island
      islands = 0
      reputations.each do |rep|
        unless @visited_rep_ids[rep.id]
          traverse_from(rep)
          islands += 1
        end
      end
    end

    # iterate 4 times
    puts "Calculating reputation network"
    islands = 0
    NUM_ITERATIONS.times do |i|
      # iteration
      start_time = Time.now
      puts "Iteration #{i} ..."
      islands = iterate(reputations)

      # update overall_rep and reset given_rep
      reputation.each do |rep|
        rep.calculate_overall_rep
        rep.given_rep = 0 if i != NUM_ITERATIONS
      end

      # tracking
      time_diff = (Time.now - beginning_time) * 1000
      puts "  #{time_diff}ms"
    end

    # reporting
    puts "#{islands} islands"
  end

  def perform
    # load all reputations so things go fast
    reputations = UserReputation.includes(:given_reputation, :user => :bio)

    # calculate reputation groups
    reputations.each do |rep|
      next if rep.dont_compute
      rep.given_rep = 0
      rep.calculate_site_rep
      rep.calculate_contribution_rep
      rep.calculate_author_rep
      rep.calculate_overall_rep
    end

    # traverse network to calculate given reputation to each user
    calculate_given_rep(reputations)

    # save changes
    reputations.each(&:save)
  end
end
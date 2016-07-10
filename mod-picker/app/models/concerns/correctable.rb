module Correctable
  extend ActiveSupport::Concern

  included do
    enum standing: [ :good, :unknown, :bad ]

    scope :editor, -> (username) { joins(:editors).where(:users => {:username => username}) }
    scope :standing, -> (standing_hash) {
      # build commentables array
      standings = []
      standing_hash.each_with_index do |(key,value),index|
        if standing_hash[key]
          standings.push(index)
        end
      end

      # return query
      where(standing: standings)
    }
    scope :corrections_count, -> (range) { where(corrections_count: range[:min]..range[:max]) }
    scope :history_entries_count, -> (range) { where(history_entries_count: range[:min]..range[:max]) }

    has_many :corrections, :as => 'correctable'
  end

  def compute_standing
    if self.corrections.where(hidden: false, status: 1).count > 0
      self.standing = :bad
    elsif self.corrections.where(hidden: false, status: 0).count > 0
      self.standing = :unknown
    else
      self.standing = :good
    end
  end
end
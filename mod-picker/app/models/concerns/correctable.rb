module Correctable
  extend ActiveSupport::Concern

  included do
    enum standing: [ :good, :unknown, :bad ]

    scope :editor, -> (username) { joins(:editors).where(:users => {:username => username}) }
    scope :standing, -> (standings) {
      if standings.is_a?(Hash)
        # handle hash search by building a standings array
        standings_array = []
        standings.each_with_index do |(key,value),index|
          if standings[key]
            standings_array.push(index)
          end
        end
      else
        # else treat as an array of standings
        standings_array = standings
      end

      # return query
      where(standing: standings_array)
    }
    scope :corrections_count, -> (range) { where(corrections_count: range[:min]..range[:max]) }
    scope :history_entries_count, -> (range) { where(history_entries_count: range[:min]..range[:max]) }

    belongs_to :corrector, :class_name => 'User'
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
module Correctable
  extend ActiveSupport::Concern

  included do
    enum standing: [ :good, :unknown, :bad ]

    user_scope :editors, :alias => 'editor'
    enum_scope :standing
    range_scope :corrections_count, :history_entries_count

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
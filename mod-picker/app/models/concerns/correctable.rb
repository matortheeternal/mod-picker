module Correctable
  extend ActiveSupport::Concern

  included do
    enum standing: [ :good, :unknown, :bad ]
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
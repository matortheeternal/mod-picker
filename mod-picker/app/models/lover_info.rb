class LoverInfo < ActiveRecord::Base
  belongs_to :mod

  validates :mod_id, presence: true
end

class ModComment < ActiveRecord::Base
  belongs_to :mod
  belongs_to :comment
end

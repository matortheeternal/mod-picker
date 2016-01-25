class ModListComment < ActiveRecord::Base
  belongs_to :mod_list
  belongs_to :comment
end

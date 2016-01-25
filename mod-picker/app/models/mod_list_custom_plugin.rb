class ModListCustomPlugin < ActiveRecord::Base
  belongs_to :mod_list, :inverse_of => 'custom_plugins'
end

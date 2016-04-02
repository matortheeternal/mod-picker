class ModListTag < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :tag_id
end

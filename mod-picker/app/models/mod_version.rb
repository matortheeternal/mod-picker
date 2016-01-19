class ModVersion < ActiveRecord::Base
  has_many :installation_notes, :inverse_of => 'mod_version'
end

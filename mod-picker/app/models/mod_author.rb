class ModAuthor < ActiveRecord::Base
  belongs_to :mod, :inverse_of => 'mod_authors'
  belongs_to :author, :class_name => 'User', :foreign_key => 'user_id', :inverse_of => 'mod_authors'

  validates :mod_id, :user_id, presence: true
end

class ModAuthor < ActiveRecord::Base
  belongs_to :mod
  belongs_to :user
end

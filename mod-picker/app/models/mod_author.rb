class ModAuthor < ActiveRecord::Base
  self.primary_keys = :mod_id, :user_id

  belongs_to :mod, :inverse_of => 'mod_authors'
  belongs_to :author, :class_name => 'User', :foreign_key => 'user_id', :inverse_of => 'mod_authors'

  validates :mod_id, :user_id, presence: true

  def self.link_author(model, user_id, username)
    infos = model.where(uploaded_by: username)

    infos.each do |info|
      ModAuthor.find_or_create_by(mod_id: info.mod_id, user_id: user_id) if info.mod_id.present?
    end
  end
end

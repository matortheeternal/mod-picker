class BlacklistedAuthor < ActiveRecord::Base
  after_create :hide_matching_mods

  def source_model
    source.safe_constantize
  end

  def hide_matching_mods
    mod_ids = source_model.where("mod_id IS NOT NULL").where(uploaded_by: author).pluck(:mod_id)
    Mod.where(id: mod_ids).each do |mod|
      mod.update(hidden: true)
    end
  end

  def self.exists_for?(source, author)
    BlacklistedAuthor.where(source: source, author: author).exists?
  end
end

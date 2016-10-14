class BlacklistedAuthor < ActiveRecord::Base
  after_create :hide_matching_mods, :destroy_unassociated_sources

  def source_model
    source.safe_constantize
  end

  def destroy_unassociated_sources
    source_model.where("mod_id IS NULL").where(uploaded_by: author).destroy_all
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

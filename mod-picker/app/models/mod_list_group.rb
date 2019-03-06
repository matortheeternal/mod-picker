class ModListGroup < ActiveRecord::Base
  include BetterJson

  # ATTRIBUTES
  enum tab: [:tools, :mods, :plugins]
  enum color: [:red, :orange, :yellow, :green, :blue, :purple, :white, :gray, :brown, :black]

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_groups'

  # VALIDATIONS
  validates :mod_list_id, :name, presence: true

  def self.nested_json(groups, mods, custom_mods)
    groups_json = groups.as_json({format: "step"})
    mods_json = mods.as_json({format: "step"}) + custom_mods.as_json({format: "step"})
    groups_json.each do |group|
      group[:children] = mods_json.
          select{ |mod| mod["group_id"] == group["id"] }.
          sort_by { |mod| mod["index"] }.
          each { |mod| mod.delete("group_id"); mod.delete("index") }
      group.delete("id")
    end
  end

  def child_model
    tab == "plugins" ? ModListPlugin : ModListMod.utility(tab.to_sym == :tools)
  end

  def custom_child_model
    tab == "plugins" ? ModListCustomPlugin : ModListCustomMod.utility(tab.to_sym == :tools)
  end

  def children
    [
        child_model.where(group_id: id).to_a,
        custom_child_model.where(group_id: id).to_a
    ].flatten.sort! { |x, y| x.index <=> y.index }
  end

  def copy_children_to(other_mod_list, index, new_group)
    children.each { |child| index = child.copy_to(other_mod_list, index, new_group.id) }
    index
  end

  def copy_attributes(mod_list_id, index)
    attributes.except("id").merge({ mod_list_id: mod_list_id, index: index })
  end

  def copy_to(other_mod_list, index)
    new_group = ModListGroup.create!(copy_attributes(other_mod_list.id, index))
    copy_children_to(other_mod_list, index, new_group)
  end
end

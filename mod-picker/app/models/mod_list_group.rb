class ModListGroup < ActiveRecord::Base
  include BetterJson

  # ATTRIBUTES
  enum tab: [:tools, :mods, :plugins]
  enum color: [:red, :orange, :yellow, :green, :blue, :purple, :white, :gray, :brown, :black]

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_groups'

  # VALIDATIONS
  validates :mod_list_id, :name, presence: true

  def child_model
    tab == :plugins ? ModListPlugin : ModListMod.utility(tab == :tools)
  end

  def children
    child_model.where(group_id: id)
  end

  def copy_children_to(other_mod_list, index, new_group)
    children.each_with_index do |child|
      index += 1 if child.copy_to(other_mod_list, index, new_group.id)
    end
  end

  def copy_attributes(mod_list_id, index)
    attributes.except("id").merge({ mod_list_id: mod_list_id, index: index })
  end

  def copy_to(other_mod_list, index)
    new_group = ModListGroup.create!(copy_attributes(other_mod_list.id, index))
    copy_children_to(other_mod_list, index, new_group)
  end
end

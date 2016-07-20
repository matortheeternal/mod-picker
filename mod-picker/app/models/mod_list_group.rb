class ModListGroup < ActiveRecord::Base
  enum tab: [:tools, :mods, :plugins]

  attr_writer :children

  belongs_to :mod_list, :inverse_of => 'mod_list_groups'

  # Validations
  validates :mod_list_id, :name, presence: true

  # Callbacks
  after_create :link_children

  def link_children
    if @children
      children_ids = @children.map { |c| c[:id] }
      if self.tab == :tools || self.tab == :mods
        ModListMod.where(id: children_ids).update_all(group_id: self.id)
      elsif self.tab == :plugins
        ModListPlugin.where(id: children_ids).update_all(group_id: self.id)
      end
    end
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:id, :tab, :color, :name, :description]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end

class ModList < EnhancedRecord::Base
  include Filterable, Sortable

  enum status: [ :planned, :"under construction", :testing, :complete ]

  belongs_to :game, :inverse_of => 'mod_lists'
  belongs_to :user, :foreign_key => 'created_by', :inverse_of => 'mod_lists'

  # INSTALL ORDER
  has_many :mod_list_mods, :inverse_of => 'mod_list'
  has_many :mods, :through => 'mod_list_mods', :inverse_of => 'mod_lists'

  # LOAD ORDER
  has_many :plugins, :through => 'mods'
  has_many :mod_list_plugins, :inverse_of => 'mod_list'
  has_many :active_plugins, :class_name => 'Plugin', :through => 'mod_list_plugins', :source => :plugins
  has_many :custom_plugins, :class_name => 'ModListCustomPlugin', :inverse_of => 'mod_list'

  # ASSOCIATED NOTES
  has_many :mod_list_compatibility_notes, :inverse_of => 'mod_list'
  #has_many :compatibility_notes, :through => 'mod_list_compatibility_notes', :inverse_of => 'mod_lists', counter_cache: false
  has_many :mod_list_install_order_notes, :inverse_of => 'mod_list'
  #has_many :install_order_notes, :through => 'mod_list_install_order_notes', :inverse_of => 'mod_lists', counter_cache: false
  has_many :mod_list_load_order_notes, :inverse_of => 'mod_list'
  #has_many :load_order_notes, :through => 'mod_list_load_order_notes', :inverse_of => 'mod_lists'

  # In the future, if conventional counter_cache naming is used then the workaround of
  # counter_cache: :this_does_not_exit
  # will need to be appended to user_stars
  has_many :mod_list_stars, :inverse_of => 'starred_mod_list'
  has_many :user_stars, :through => 'mod_list_stars', :inverse_of => 'starred_mod_lists'

  has_many :mod_list_tags, :inverse_of => 'mod_list'
  has_many :tags, :through => 'mod_list_tags', :inverse_of => 'mod_lists'

  has_many :comments, :as => 'commentable'
  has_one :base_report, :as => 'reportable'

  # Validations
  validates :game_id, presence: true 
  validates_inclusion_of :is_collection, :hidden, :has_adult_content, {in: [true, false], 
                                          message: "must be true or false"}
  validates :description, length: { maximum: 65535 }

  def refresh_compatibility_notes
    mod_ids = mod_list_mods.all.ids
    cnote_ids = CompatibilityNote.where("first_mod_id in ? AND second_mod_id in ?", mod_ids, mod_ids).ids
    # delete compatibility notes that are no longer relevant
    cnotes = self.mod_list_compatibility_notes.all
    cnotes.each do |c|
      if cnote_ids.exclude?(c.compatibility_note_id)
        c.delete
      end
    end
    # add new compatibility notes
    current_cnote_ids = cnotes.ids
    cnote_ids.each do |id|
      if current_cnote_ids.exclude?(id)
        self.mod_list_compatibility_notes.create(compatibility_note_id: id)
      end
    end
  end

  def refresh_install_order_notes
    mod_ids = mod_list_mods.all.ids
    inote_ids = InstallOrderNote.where("first_mod_id in ? AND second_mod_id in ?", mod_ids, mod_ids).ids
    # delete install order notes that are no longer relevant
    inotes = self.mod_list_install_order_notes.all
    inotes.each do |n|
      if inote_ids.exclude?(n.install_order_note_id)
        n.delete
      end
    end
    # add new install order notes
    current_inote_ids = inotes.ids
    inote_ids.each do |id|
      if current_inote_ids.exclude?(id)
        self.mod_list_install_order_notes.create(install_order_note_id: id)
      end
    end
  end

  def refresh_load_order_notes
    plugin_ids = plugins.all.ids
    lnote_ids = LoadOrderNote.where("first_plugin_id in ? AND second_plugin_id in ?", plugin_ids, plugin_ids).ids
    # delete load order notes that are no longer relevant
    lnotes = self.mod_list_load_order_notes.all
    lnotes.each do |n|
      if lnote_ids.exclude?(n.load_order_note_id)
        n.delete
      end
    end
    # add new load order notes
    current_lnote_ids = lnotes.ids
    lnote_ids.each do |id|
      if current_lnote_ids.exclude?(id)
        self.mod_list_load_order_notes.create(load_order_note_id: id)
      end
    end
  end

  def incompatible_mods
    mod_ids = mod_list_mods.all.ids
    incompatible_notes = CompatibilityNote.where("compatibility_type in ? AND (first_mod_id in ? OR second_mod_id in ?)", [1, 2], mod_ids, mod_ids)
    incompatible_mod_ids = []
    incompatible_notes.each do |n|
      first_id = n.first_mod_id
      second_id = n.second_mod_id
      incompatible_mod_ids.push(first_id) if mod_ids.exclude?(first_id)
      incompatible_mod_ids.push(second_id) if mod_ids.exclude?(second_id)
    end
    incompatible_mod_ids.uniq
  end
end

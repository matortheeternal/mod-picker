class ModList < ActiveRecord::Base

  after_initialize :init

  enum status: [ :planned, :"under construction", :testing, :complete ]

  belongs_to :game, :inverse_of => 'mod_lists'
  belongs_to :user, :foreign_key => 'created_by', :inverse_of => 'mod_lists'

  has_many :mods, :through => 'mod_list_mods', :inverse_of => 'mod_lists', counter_cache: :this_does_not_exist_mods
  has_many :mod_list_mods, :inverse_of => 'mod_list'
  has_many :plugins, :through => 'mod_list_plugins', :inverse_of => 'mod_lists', counter_cache: :this_does_not_exist_plugins
  has_many :mod_list_plugins, :inverse_of => 'mod_list'
  has_many :custom_plugins, :class_name => 'ModListCustomPlugin', :inverse_of => 'mod_list'

  has_many :mod_list_compatibility_notes, :inverse_of => 'mod_list'
  has_many :compatibility_notes, :through => 'mod_list_compatibility_notes', :inverse_of => 'mod_lists', counter_cache: :this_does_not_exist_compatibility_note
  has_many :mod_list_install_order_notes, :inverse_of => 'mod_list'
  has_many :install_order_notes, :through => 'mod_list_install_order_notes', :inverse_of => 'mod_lists', counter_cache: :this_does_not_exist_install_order_notes
  has_many :mod_list_load_order_notes, :inverse_of => 'mod_list'
  has_many :load_order_notes, :through => 'mod_list_load_order_notes', :inverse_of => 'mod_lists'

  # In the future, if conventional counter_cache naming is used then the workaround of
  # counter_cache: :this_does_not_exit
  # will need to be appended to user_stars
  has_many :mod_list_stars, :inverse_of => 'starred_mod_list'
  has_many :user_stars, :through => 'mod_list_stars', :inverse_of => 'starred_mod_lists'

  has_many :mod_list_tags, :inverse_of => 'mod_list'
  has_many :tags, :through => 'mod_list_tags', :inverse_of => 'mod_lists'

  has_many :comments, :as => 'commentable'

  # Validations
  validates :game_id, presence: true 
  validates_inclusion_of :is_collection, :hidden, :has_adult_content, {in: [true, false], 
                                          message: "must be true or false"}
  validates :description, length: { maximum: 65535 }

  def init
    self.is_collection ||= false
    self.created ||= DateTime.now
  end                                         
end

class CuratorRequest < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache, ScopeHelpers, Searchable, Filterable, Sortable, Dateable

  # ATTRIBUTES
  enum state: [:open, :approved, :denied]

  # DATE COLUMNS
  date_column :submitted, :updated

  # SCOPES
  enum_scope :state
  date_scope :submitted, :updated

  # UNIQUE SCOPES
  # TODO: Move this into search scopes
  scope :mod_name, -> (name) { where("mods.name LIKE ?", "%#{name}%") }
  scope :game, -> (game_id) { where("mods.game_id = ?", game_id) }

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'curator_requests'
  belongs_to :mod, :inverse_of => 'curator_requests'

  # VALIDATIONS
  validates :submitted_by, :mod_id, :text_body, presence: true

  # CALLBACKS
  before_update :toggle_curator

  def self.unapproved_count
    where(state: CuratorRequest.states[:open]).count
  end

  def curator_attributes
    { mod_id: mod_id, user_id: submitted_by, role: 2 }
  end

  def create_curator
    curator_record = ModAuthor.where(curator_attributes.except(:role)).first
    ModAuthor.create!(curator_attributes) if curator_record.nil?
  end

  def destroy_curator
    curator_record = ModAuthor.where(curator_attributes).first
    curator_record.destroy unless curator_record.nil?
  end

  def toggle_curator
    if attribute_changed?(:state)
      create_curator if state == "approved"
      destroy_curator if attribute_was(:state) == "approved"
    end
    true
  end
end

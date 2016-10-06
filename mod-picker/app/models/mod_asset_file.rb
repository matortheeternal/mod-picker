class ModAssetFile < ActiveRecord::Base
  include ScopeHelpers

  self.primary_keys = :mod_option_id, :asset_file_id

  # SCOPES
  ids_scope :mod_option_id

  # UNIQUE SCOPES
  scope :bsa, -> { joins(:asset_file).where("asset_files.path like '%.bsa'") }
  scope :conflicting, -> (mod_option_ids) {
    maf = arel_table
    maf_right = arel_table.alias
    mo = ModOption.arel_table
    mo_right = ModOption.arel_table.alias

    joins(conflicting_join_query(maf, maf_right, mo, mo_right).join_sources).
        where(mo[:mod_id].not_eq(mo_right[:mod_id])).
        where(maf[:asset_file_id].not_eq(nil)).
        where(maf[:mod_option_id].in(mod_option_ids)).
        where(maf_right[:mod_option_id].in(mod_option_ids)).
        order(maf[:asset_file_id])
  }

  # ASSOCIATIONS
  belongs_to :mod_option, :inverse_of => 'mod_asset_files'
  has_one :mod, :through => 'mod_option', :inverse_of => 'mod_asset_files'
  belongs_to :asset_file, :inverse_of => 'mod_asset_files'

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def self.conflicting_join_query(maf, maf_right, mo, mo_right)
    maf.join(maf_right).on(maf[:asset_file_id].eq(maf_right[:asset_file_id])).
        join(mo).on(mo[:id].eq(maf[:mod_option_id])).
        join(mo_right).on(mo_right[:id].eq(maf_right[:mod_option_id]))
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [],
          :include => {
              :asset_file => {
                  :only => [:path]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def increment_counters
      asset_file.update_counter(:mod_asset_files_count, 1) if asset_file_id
    end

    def decrement_counters
      asset_file.update_counter(:mod_asset_files_count, -1) if asset_file_id
    end
end

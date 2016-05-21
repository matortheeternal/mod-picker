class RecordGroup < EnhancedRecord::Base
  belongs_to :game, :inverse_of => 'record_groups'

  def self.as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [:id, :game_id]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end

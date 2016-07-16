class RecordGroup < ActiveRecord::Base
  belongs_to :game, :inverse_of => 'record_groups'

  # Validations
  validates :game_id, :signature, :name, presence: true
  validates :signature, length: {is: 4}
  validates :name, length: {maximum: 64}

  def as_json(options={})
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

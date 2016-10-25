class LoadOrderNoteBuilder
  attr_accessor :note, :current_user, :params, :first_plugin_id, :second_plugin_id

  def builder_attributes
    [:first_plugin_id, :second_plugin_id]
  end

  def initialize(current_user, params={})
    @current_user = current_user
    @params = params.except(*builder_attributes)
    builder_attributes.each do |attribute|
      send(:"#{attribute}=", params[attribute]) if params.has_key?(attribute)
    end
  end

  def note
    if @note.present?
      @note
    elsif @params && @params[:id]
      @note = @note.find_or_initialize_by(id: @params[:id])
    else
      @note = LoadOrderNote.new
    end
  end

  def errors
    @note.errors
  end

  def get_existing_note(plugin_ids)
    table = @note.arel_table
    LoadOrderNote.plugins(plugin_ids).where(table[:hidden].eq(0)).first
  end

  def note_exists_error(existing_note)
    if existing_note.approved
      errors.add(:plugins, "A Load Order Note for these plugins already exists.")
      errors.add(:link_id, existing_note.id)
    else
      errors.add(:plugins, "An unapproved Load Order Note for these plugins already exists.")
    end
  end


  def duplicate_plugins_error
    errors.add(:plugins, "You cannot create a Load Order Note between a plugin and itself.") if @first_plugin_id == @second_plugin_id
  end

  def validate_unique_plugins
    return if duplicate_plugins_error
    existing_note = get_existing_note([@first_plugin_id, @second_plugin_id])
    note_exists_error(existing_note) if existing_note.present?
  end

  def prepare
    note.assign_attributes(@params)
    note.submitted_by = @current_user.id
    note
  end

  def save
    save!
    true
  rescue
    false
  end

  def save!
    ActiveRecord::Base.transaction do
      self.before_save
      note.save!
      self.after_save
    end
  end

  def before_save
    validate_unique_plugins
  end

  def after_save
    create_plugin_load_order_notes
  end

  def create_plugin_load_order_note(plugin_id, index)
    PluginLoadOrderNote.create({
        plugin_id: plugin_id,
        load_order_note_id: note.id,
        index: index
    })
  end

  def create_plugin_load_order_notes
    create_plugin_load_order_note(@first_plugin_id, 0)
    create_plugin_load_order_note(@second_plugin_id, 1)
  end
end
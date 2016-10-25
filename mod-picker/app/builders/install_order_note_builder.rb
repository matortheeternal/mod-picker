class InstallOrderNoteBuilder
  attr_accessor :note, :current_user, :params, :first_mod_id, :second_mod_id

  def builder_attributes
    [:first_mod_id, :second_mod_id]
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
      @note = InstallOrderNote.new
    end
  end

  def errors
    @note.errors
  end

  def get_existing_note(mod_ids)
    table = @note.arel_table
    InstallOrderNote.mods(mod_ids).where(table[:hidden].eq(0)).first
  end

  def note_exists_error(existing_note)
    if existing_note.approved
      errors.add(:mods, "An Install Order Note for these mods already exists.")
      errors.add(:link_id, existing_note.id)
    else
      errors.add(:mods, "An unapproved Install Order Note for these mods already exists.")
    end
  end

  def duplicate_mods_error
    errors.add(:mods, "You cannot create a Install Order Note between a mod and itself.") if @first_mod_id == @second_mod_id
  end

  def validate_unique_mods
    return if duplicate_mods_error
    existing_note = get_existing_note([@first_mod_id, @second_mod_id])
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
    validate_unique_mods
  end

  def after_save
    create_mod_install_order_notes
  end

  def create_mod_install_order_note(mod_id, index)
    ModInstallOrderNote.create({
        mod_id: mod_id,
        install_order_note_id: note.id,
        index: index
    })
  end

  def create_mod_install_order_notes
    create_mod_install_order_note(@first_mod_id, 0)
    create_mod_install_order_note(@second_mod_id, 1)
  end
end
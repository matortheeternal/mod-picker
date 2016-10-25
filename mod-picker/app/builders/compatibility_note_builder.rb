class CompatibilityNoteBuilder < NoteBuilder
  attr_accessor :first_mod_id, :second_mod_id

  def model
    CompatibilityNote
  end

  def builder_attributes
    [:first_mod_id, :second_mod_id]
  end

  def get_existing_note(mod_ids)
    table = @note.arel_table
    CompatibilityNote.mods(mod_ids).where(table[:hidden].eq(0)).first
  end

  def note_exists_error(existing_note)
    if existing_note.approved
      errors.add(:mods, "An Compatibility Note for these mods already exists.")
      errors.add(:link_id, existing_note.id)
    else
      errors.add(:mods, "An unapproved Compatibility Note for these mods already exists.")
    end
  end

  def duplicate_mods_error
    errors.add(:mods, "You cannot create a Compatibility Note between a mod and itself.") if @first_mod_id == @second_mod_id
  end

  def validate_unique_mods
    return if duplicate_mods_error
    existing_note = get_existing_note([@first_mod_id, @second_mod_id])
    note_exists_error(existing_note) if existing_note.present?
  end

  def before_save
    validate_unique_mods
  end

  def after_save
    create_mod_compatibility_notes
  end

  def create_mod_compatibility_note(mod_id, index)
    ModCompatibilityNote.create({
        mod_id: mod_id,
        compatibility_note_id: note.id,
        index: index
    })
  end

  def create_mod_compatibility_notes
    create_mod_compatibility_note(@first_mod_id, 0)
    create_mod_compatibility_note(@second_mod_id, 1)
  end
end
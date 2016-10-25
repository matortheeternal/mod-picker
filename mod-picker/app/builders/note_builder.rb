class NoteBuilder
  attr_accessor :note, :current_user, :params

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
      @note = model.find_or_initialize_by(id: @params[:id])
    else
      @note = model.new
    end
  end

  def errors
    @note.errors
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
end
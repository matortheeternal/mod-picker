class Builder
  attr_accessor :resource, :current_user, :params

  # core class methods
  def self.model_name
    resource_class.name
  end

  def self.update(id, current_user, params)
    params[:id] = id
    builder = new(current_user, params)
    builder.update
  end

  def self.create(current_user, params)
    builder = new(current_user, params)
    builder.save
  end

  # core instance methods
  def builder_attributes
    []
  end

  def initialize(current_user, params={})
    @current_user = current_user
    @params = params.except(*builder_attributes)
    builder_attributes.each do |attribute|
      send(:"#{attribute}=", params[attribute]) if params.has_key?(attribute)
    end
  end

  def resource
    if @resource.present?
      @resource
    elsif @params && @params[:id]
      @resource = resource_class.find_or_initialize_by(id: @params[:id])
    else
      @resource = resource_class.new
    end
  end

  def errors
    @resource.errors
  end

  # updated_by and created_by tracking
  def updated_by_key
    "updated_by"
  end

  def created_by_key
    "created_by"
  end

  def set_updated_by
    resource.public_send("#{updated_by_key}=", current_user.id)
  end

  def set_created_by
    resource.public_send("#{created_by_key}=", current_user.id)
  end

  # update/save wrappers
  def update
    set_updated_by
    update!
    true
  rescue Exception => x
    raise x unless resource.errors.present?
    false
  end

  def update!
    ActiveRecord::Base.transaction do
      resource.attributes = @params
      self.before_save
      self.before_update
      resource.save!
      self.after_update
      self.after_save
    end
  end

  def save
    resource.assign_attributes(@params)
    set_created_by
    save!
    true
  rescue Exception => x
    raise x unless mod.errors.present?
    false
  end

  def save!
    ActiveRecord::Base.transaction do
      self.before_save
      resource.save!
      self.after_save
    end
  end

  # before/after methods
  def before_save
  end

  def after_save
  end

  def before_update
  end

  def after_update
  end
end
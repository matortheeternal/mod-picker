class TagBuilder
  attr_accessor :resource, :current_user, :current_ability, :tag_names
  attr_reader   :errors

  def initialize(resource, current_user, tag_names)
    @resource = resource
    @current_user = current_user
    @current_ability = Ability.new(current_user)
    @tag_names = tag_names || []
    @errors = ActiveModel::Errors.new(self)
  end

  def self.update_tags(resource, current_user, tag_names)
    builder = TagBuilder.new(resource, current_user, tag_names)
    builder.update_tags
  end

  def update_tags
    destroy_removed_tags
    create_new_tags
  rescue Exception => x
    errors.add(:tags, x.message)
    false
  end

  def resource_tags
    @resource_tags ||= public_send("#{@resource.class.table_name.singularize}_tags")
  end

  def existing_tags_text
    @existing_tags_text = @resource.tags.pluck(:text)
  end

  def mod_tags
    @resource.mod_tags
  end

  def mod_list_tags
    @resource.mod_list_tags
  end

  def destroy_removed_tags
    resource_tags.each_with_index do |resource_tag, index|
      next unless @tag_names.exclude?(existing_tags_text[index])
      current_ability.authorize! :destroy, resource_tag
      resource_tag.destroy
    end
  end

  def create_new_tags
    @tag_names.each do |text|
      next unless existing_tags_text.exclude?(text)
      tag = find_or_create_tag(text)
      associate_tag_with_resource(tag)
    end
  end

  def find_or_create_tag(text)
    Tag.find_by(game_id: @resource.game_id, text: text) || Tag.create!({
        text: text,
        game_id: @resource.game_id,
        submitted_by: @current_user.id
    })
  end

  def associate_tag_with_resource(tag)
    new_tag = resource_tags.new(tag_id: tag.id, submitted_by: @current_user.id)
    current_ability.authorize! :create, new_tag
    new_tag.save!
  end
end
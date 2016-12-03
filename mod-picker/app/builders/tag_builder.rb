class TagBuilder
  attr_accessor :resource, :current_user

  def initialize(resource, current_user)
    self.resource = resource
    self.current_user = current_user
  end

  def self.create_tags(resource, current_user, tag_names)
    builder = TagBuilder.new(resource, current_user)
    builder.create_tags(tag_names)
  end

  def create_tags(tag_names)
    tag_names.each do |text|
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
    public_send("associate_tag_with_#{@resource.table_name.singularize}", tag)
  end

  def associate_tag_with_mod(tag)
    ModTag.create!({
        mod_id: @resource.id,
        tag_id: tag.id,
        submitted_by: @current_user.id
    })
  end

  def associate_tag_with_mod_list(tag)
    ModListTag.create!({
        mod_list_id: @resource.id,
        tag_id: tag.id,
        submitted_by: @current_user.id
    })
  end
end
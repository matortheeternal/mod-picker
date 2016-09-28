# Better name pending
module BetterJson
  extend ActiveSupport::Concern

  included do
    class_attribute :_json_template_cache
    self._json_template_cache = {}
  end

  # noinspection RubySuperCallWithoutSuperclassInspection
  def as_json(options={})
    if json_options_empty(options)
      super(get_json_template(options[:template] || :base))
    else
      super(options)
    end
  end

  def json_options_empty(options)
    keys = [:include, :only, :except, :methods]
    !(options.keys & keys).any?
  end

  def get_json_template(template)
    self.class._json_template_cache[template] || load_json_template(template)
  end

  def load_json_template(template)
    file = File.read(json_template_path(template))
    self.class._json_template_cache[template] = JSON.parse(file)
  end

  def json_template_path(template)
    Rails.root.join('app', 'views', self.class.name.underscore.pluralize, "#{template}.json")
  end
end
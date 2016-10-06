# Better name pending
module BetterJson
  extend ActiveSupport::Concern

  included do
    class_attribute :_json_template_cache
    self._json_template_cache = {}
  end

  def init_key(options, key)
    if key == :include
      options[key] = {}
    else
      options[key] = []
    end
  end

  def add_option(options, key, new_option)
    init_key(options, key) unless options.has_key?(key)
    if key == :include
      options[key].merge(new_option)
    else
      options[key].push(new_option)
    end
  end

  def build_conditional_option(options, key)
    conditional_key = ("conditional_" + key.to_s).to_sym
    return unless options.has_key?(conditional_key)
    options[conditional_key].each do |conditional_option|
      add_option(options, key, conditional_option[key]) if instance_eval(conditional_option[:if])
    end
  end

  def build_conditional_options(options)
    [:only, :except, :methods, :include].each do |key|
      build_conditional_option(options, key)
    end
    options
  end

  def insert_templates(options)
    if json_options_empty(options)
      options = get_json_template(options[:format] || :base)
    end
    build_conditional_options(options)
  end

  def insert_includes(result, options)
    options[:include].each do |key, value|
      result[key] = public_send(key).as_json(value.symbolize_keys)
    end
  end

  # noinspection RubySuperCallWithoutSuperclassInspection
  def as_json(options={})
    options = insert_templates(options)
    result = super(options.except(:include))
    insert_includes(result, options) if options.has_key?(:include)
    result
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
    self.class._json_template_cache[template] = JSON.parse(file).symbolize_keys
  end

  def json_template_path(template)
    Rails.root.join('app', 'views', self.class.name.underscore.pluralize, "#{template}.json")
  end
end
# Better name pending
module BetterJson
  extend ActiveSupport::Concern

  included do
    class_attribute :_json_template_cache
    self._json_template_cache = {}
  end

  def init_key(options, key)
    options[key] = key == :include ? {} : []
  end

  def add_option(options, key, new_option)
    init_key(options, key) unless options.has_key?(key)
    add_method = key == :include ? :merge : :push
    options[key].public_send(add_method, new_option)
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

  def inherit_template(options)
    get_json_template(options[:inherit_from]).merge(options)
  end

  def build_template(options)
    options = get_json_template(options[:format] || :base) if json_options_empty(options)
    options = inherit_template(options) if options.has_key?(:inherit_from)
    build_conditional_options(options)
  end

  def insert_includes(result, options)
    options[:include].each do |key, value|
      result[key] = public_send(key).as_json(value.symbolize_keys)
    end
  end

  # noinspection RubySuperCallWithoutSuperclassInspection
  def as_json(options={})
    options = build_template(options)
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
    file_path = json_template_path(template)
    unless File.exists?(file_path)
      raise "JSON Template #{file_path} not found" if raise_template_exception?(template)
      return {}
    end
    parse_template(template, file_path)
  end

  def parse_template(template, file_path)
    template_hash = JSON.parse(File.read(file_path)).symbolize_keys
    self.class._json_template_cache[template] = template_hash if cache_templates?
    template_hash
  end

  def check_config(key)
    config = Rails.application.config
    config.respond_to?(key) && config.public_send(key)
  end

  def cache_templates?
    check_config(:cache_json_templates)
  end

  def raise_template_exception?(template)
    template != :base && check_config(:raise_template_not_found_exceptions)
  end

  def json_template_path(template)
    Rails.root.join('app', 'views', self.class.name.underscore.pluralize, "#{template}.json")
  end
end
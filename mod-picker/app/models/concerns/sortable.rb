module Sortable
  extend ActiveSupport::Concern

  included do
    class_attribute :sortable_columns
    self.sortable_columns = {}
    load_sortable_columns
  end

  module ClassMethods
    def sortable_columns_path
      filename = name.underscore.pluralize + ".json"
      Rails.root.join('app', 'models', 'sortable_columns', filename)
    end

    def load_sortable_columns
      file_path = sortable_columns_path
      return unless File.exists?(file_path)
      self.sortable_columns = JSON.parse(File.read(file_path)).deep_symbolize_keys
    end

    def key_allowed(key, opts)
      return false if opts.has_key?(:except) && opts[:except].include?(key)
      return false if opts.has_key?(:only) && opts[:only].exclude?(key)
      true
    end

    def included_columns(model, options)
      columns = allowed_columns(model, options)
      columns.map do |column|
        column.include?('.') ? column : "#{model.table_name}.#{column}"
      end
    end

    def include_association_columns(columns, model, options)
      return columns unless options.has_key?(:include)
      options[:include].each do |key, value|
        reflection = model.reflections[key.to_s]
        columns.push(*included_columns(reflection.klass, value))
      end
      columns
    end

    def allowed_columns(model, options)
      columns = model.columns_hash.select do |key, value|
        value.type != :boolean && key_allowed(key, options)
      end
      include_association_columns(columns.keys.dup, model, options)
    end

    def check_options(options)
      unless ['ASC', 'DESC'].include?(options[:direction])
        raise "Sort direction must be ASC or DESC"
      end

      columns = allowed_columns(self, self.sortable_columns)
      option_columns = options[:column].split(',')
      unless (option_columns - columns).empty?
        raise "Sorting on column #{options[:column]} is not allowed!"
      end
    end

    def sanitize_column(column)
      column.split('.').map{ |column| connection.quote_column_name(column) }.join('.')
    end

    def sanitize_columns(columns)
      columns.split(',').map{ |column| sanitize_column(column) }.join(',')
    end

    def apply_sort_options(options)
      if options[:column].include?(',')
        order("GREATEST(#{sanitize_columns(options[:column])}) #{options[:direction]}")
      elsif options[:column].include?('.')
        order("#{sanitize_column(options[:column])} #{options[:direction]}")
      else
        # this is necessary so the column we're sorting on won't be ambiguous
        order(options[:column] => options[:direction])
      end
    end

    def sort(options)
      results = self.where(nil)
      if options.present? && options.has_key?(:column) && options.has_key?(:direction)
        check_options(options)
        results = apply_sort_options(options)
      end
      results
    end
  end
end
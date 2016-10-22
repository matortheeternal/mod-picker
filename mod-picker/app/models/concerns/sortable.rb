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
      self.sortable_columns = JSON.parse(File.read(file_path)).symbolize_keys
    end

    def key_allowed(key, opts)
      key = key.to_sym
      return false if opts.has_key?(:except) && opts[:except].include?(key)
      return false if opts.has_key?(:only) && opts[:only].exclude?(key)
      true
    end

    def included_columns(model, options)
      columns = allowed_columns(model, options)
      columns.map do |column|
        column.include?('.') ? column : "#{table_name}.#{column}"
      end
    end

    def include_association_columns(columns, model, options)
      return columns unless options.has_key?(:include)
      options[:include].each do |key, value|
        reflection = model.reflections[key.to_s]
        columns.push(*included_columns(reflection, value))
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
      column.split('.').map{|column| connection.quote_column_name(column) }.join('.')
    end

    def sort(options)
      results = self.where(nil)

      if options.present? && options.has_key?(:column) && options.has_key?(:direction)
        check_options(options)

        # NOTE: This is safe against SQL injection because we are strong-arming
        # the allowing options in check_options
        if options[:column].include?(",")
          columns = options[:column].split(',').map{|column| sanitize_column(column)}
          results = results.
              order("GREATEST(#{columns.join(',')}) #{options[:direction]}")
        elsif options[:column].include?(".")
          results = results.order("#{sanitize_column(options[:column])} #{options[:direction]}")
        else
          results = results.order(options[:column] => options[:direction])
        end
      end
      results
    end
  end
end
module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def allowed_columns(model, options)
      only_keys = options[:only]
      excluded_keys = options[:except]
      columns = model.columns_hash.select do |key, value|
        value.type != :boolean &&
            (!excluded_keys || !excluded_keys.include?(key.to_sym)) &&
            (!only_keys || only_keys.include?(key.to_sym))
      end
      columns = columns.keys

      # include association columns
      if options.has_key?(:include)
        options[:include].each do |key, value|
          if !model.reflections.has_key?(key.to_s)
            raise "Could not find association #{key} on #{self.class.name}"
          end

          reflection_model = model.reflections[key.to_s].klass
          included_columns = allowed_columns(reflection_model, value)
          included_columns.each do |column|
            if !column.include?('.')
              columns.push("#{reflection_model.table_name}.#{column}")
            else
              columns.push(column)
            end
          end
        end
      end

      columns
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
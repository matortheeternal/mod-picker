module Dateable
  extend ActiveSupport::Concern

  included do
    class_attribute :_date_columns
    self._date_columns = {}
  end

  def update_date_column(column)
    public_send("#{column}=", DateTime.now)
  end

  def submitted_column_was_not_nil?
    submitted_column = self.class._date_columns.find do |column, options|
      options[:type] == :submitted
    end
    attribute_was(submitted_column[0]).present?
  end

  def set_submitted_date_column(column)
    update_date_column(column) if public_send(column).nil?
  end

  def set_edited_date_column(column)
    update_date_column(column) if submitted_column_was_not_nil?
  end

  def eval_dateable_conditions(options)
    return true unless options.has_key?(:conditional)
    instance_eval(options[:conditional])
  end

  def set_custom_date_column(column, options)
    update_date_column(column) if eval_dateable_condition(options)
  end

  def set_date_column(column, options)
    unless [:submitted, :edited, :custom].include?(options[:type])
      raise "Unknown column type #{options[:type]}"
    end
    public_send("set_#{options[:type]}_date_column", column, options)
  end

  def create_set_dates_callback_if_missing
    return if respond_to?(:set_dates)
    class_eval do
      before_save :set_dates
      def set_dates
        self.class._date_columns.each do |column, options|
          set_date_column(column, options)
        end
      end
    end
  end

  def dateable_columns(date_type)
    config = Rails.application.config
    case date_type
      when :submitted
        return config.submitted_columns || [:submitted]
      when :edited
        return config.edited_columns || [:edited]
      else
        return []
    end
  end

  def get_date_type(column)
    if dateable_columns(:submitted).include?(column)
      :submitted
    elsif dateable_columns(:edited).include?(column)
      :edited
    else
      :custom
    end
  end

  def build_date_options(column, options)
    options[:type] = get_date_type(column) unless options.has_key?(:type)
    options
  end

  def date_column(*columns, **options)
    columns.each { |column|
      _date_columns[column] = build_date_options(column, options) }
    create_set_dates_callback_if_missing
  end
end
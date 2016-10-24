# COUNTER CACHE FUNCTIONS
# - Can increment/decrement a single counter on a single record
# - Can reset a single counter for a single record (using joins)
# - Can reset a single counter for multiple records (using joins)
# - Can reset a multiple counters for a single record (using joins)
# - Can reset a multiple counters for multiple records (using joins)
# - Can reset all counters for a single record (using joins)
# - Can reset all counters for all records (using joins)
#
# MACROS
#
# counter_cache :name, conditional: "visible?"
#
# CODE

module CounterCache
  extend ActiveSupport::Concern

  included do
    attr_accessor :_previous_conditionals
    class_attribute :_counter_cache
    class_attribute :_counter_cache_on
    self._counter_cache = {}
    self._counter_cache_on = {}
  end

  def update_counter(column, offset)
    # update counter in memory
    self[column] += offset
    # update column directly so we don't trigger callbacks
    operator = offset < 0 ? '-' : '+'
    update_column("#{column} = #{column} #{operator} #{offset.abs}")
  end

  def resolve_conditional_association(name, options)
    return public_send(name) unless options.has_key?(:conditional)
    public_send(name).where(options[:conditional])
  end

  def reset_counter(name, column=nil)
    options = self.class._counter_cache[name.to_sym]
    column ||= options[:column]
    self[column] = resolve_conditional_association(name, options).count
  end

  def reset_counter!(name, column=nil)
    column ||= self.class._counter_cache[name.to_sym][:column]
    reset_counter(name, column)
    update_column(column, self[column])
  end

  def reset_counters!(*names)
    column_values = {}
    _counter_cache.each do |name, options|
      next unless names.include?(name)
      column = options[:column]
      reset_counter(name, column)
      column_values[column] = self[column]
    end
    update_columns(column_values)
  end

  def reset_all_counters!
    column_values = {}
    _counter_cache.each do |name, options|
      column = options[:column]
      reset_counter(name, column)
      column_values[column] = self[column]
    end
    update_columns(column_values)
  end

  def get_counter_change(name, options)
    return 0 unless options.has_key?(:conditional)
    old_value = _previous_conditionals[name]
    new_value = eval_counter_condition(options)
    new_value == old_value ? 0 : (new_value ? 1 : -1)
  end

  def eval_counter_condition(options)
    return true unless options.has_key?(:conditional)
    options[:conditional].reduce(true) do |result, (k, v)|
      result = result && public_send(k) == v
    end
  end

  def counter_condition_was(options)
    return true unless options.has_key?(:conditional)
    options[:conditional].reduce(true) do |result, (k, v)|
      result = result && attribute_was(k) == v
    end
  end

  def update_association_counter(name, column, change)
    association = public_send(name)
    association.update_counter(column, change) if association.present?
  end

  module ClassMethods
    def apply_conditional_to_subquery(subquery, subquery_table, options)
      return subquery unless options.has_key?(:conditional)
      subquery.where(options[:conditional].map { |(k, v)|
        subquery_table[k].eq(v)
      }.inject(:and))
    end

    def count_subquery(name, options)
      reflection = reflections[name.to_s]
      subquery_table = reflection.klass.arel_table
      subquery = subquery_table.where(arel_table[:id].
          eq(subquery_table[reflection.foreign_key.to_sym])).
          project(Arel.sql('*').count)
      apply_conditional_to_subquery(subquery, subquery_table, options)
    end

    def reset_counter_query(name, column=nil)
      options = _counter_cache[name.to_sym]
      column ||= options[:column]
      arel_table[column].eq(count_subquery(name, options)).to_sql
    end

    def reset_counter!(name, column=nil)
      update_all(reset_counter_query(name, column))
    end

    def reset_counters!(*names)
      query = names.map { |name| reset_counter_query(name) }
      update_all(query.join(', '))
    end

    def reset_all_counters!
      reset_counters!(*_counter_cache.keys)
    end

    def create_track_counter_conditionals_callback
      return if self.respond_to?(:track_counter_conditionals)
      class_eval do
        before_update :track_counter_conditionals
        def track_counter_conditionals
          self._previous_conditionals = {}
          self.class._counter_cache_on.each do |name, options|
            next unless options.has_key?(:conditional)
            self._previous_conditionals[name] = counter_condition_was(options)
          end
        end
      end
    end

    def create_change_counters_callback
      return if respond_to?(:change_counters)
      class_eval do
        after_update :change_counters
        def change_counters
          self.class._counter_cache_on.each do |name, options|
            change = get_counter_change(name, options)
            next unless change != 0
            update_association_counter(name, options[:column], change)
          end
        end
      end
    end

    def create_increment_counters_callback
      return if respond_to?(:increment_counters)
      class_eval do
        after_create :increment_counters
        def increment_counters
          self.class._counter_cache_on.each do |name, options|
            next unless eval_counter_condition(options)
            update_association_counter(name, options[:column], 1)
          end
        end
      end
    end

    def create_decrement_counters_callback
      return if respond_to?(:decrement_counters)
      class_eval do
        before_destroy :decrement_counters
        def decrement_counters
          self.class._counter_cache_on.each do |name, options|
            next unless eval_counter_condition(options)
            update_association_counter(name, options[:column], -1)
          end
        end
      end
    end

    def create_counter_callbacks_if_missing
      create_increment_counters_callback
      create_decrement_counters_callback
      create_track_counter_conditionals_callback
      create_change_counters_callback
    end

    def counter_cache_column(name, options)
      options[:column] = (name.to_s + '_count').to_sym unless options.has_key?(:column)
      options
    end

    def counter_cache_on_column(options)
      options[:column] = (table_name.to_s + '_count').to_sym unless options.has_key?(:column)
      options
    end

    def counter_cache(*names, **options)
      names.each do |name|
        _counter_cache[name] = counter_cache_column(name, options.dup)
      end
    end

    def counter_cache_on(*names, **options)
      names.each do |name|
        _counter_cache_on[name] = counter_cache_on_column(options.dup)
      end
      create_counter_callbacks_if_missing
    end
  end
end
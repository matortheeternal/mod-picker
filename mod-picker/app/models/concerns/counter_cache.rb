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
    class_attribute :_counter_caches
    self._counter_caches = {}
  end

  def update_counter(column, offset)
    # update counter in memory
    self[column] += offset
    # update column directly so we don't trigger callbacks
    operator = offset < 0 ? '-' : '+'
    update_column("#{column} = #{column} #{operator} #{offset.abs}")
  end

  def reset_counter(name, column)
    self[column] = public_send(name).count
  end

  def reset_counter!(name, column)
    self[column] = public_send(name).count
    update_column(column: self[column])
  end

  def reset_counters(*names)
    column_values = {}
    _counter_caches.each do |name, options|
      next unless names.include?(name)
      reset_counter(name, options[:column]
    end
  end

  def reset_all_counters
    _counter_caches.each do |name, |

    end
  end

  def get_counter_change(name, options)
    return 0 unless options.has_key?(:conditional)
    old_value = _previous_conditionals[name]
    new_value = eval_counter_condition(options)
    new_value == old_value ? 0 : (new_value ? 1 : -1)
  end

  def eval_counter_condition(options)
    return true unless options.has_key?(:conditional)
    instance_eval(options[:conditional])
  end

  def update_association_counter(name, column, change)
    association = public_send(name)
    association.update_counter(column, change) if association.present?
  end

  module ClassMethods
    def reset_counter(association_name)

    end

    def reset_counters(*association_names)

    end

    def reset_all_counters

    end

    def create_track_counter_conditionals_callback
      return if self.respond_to?(:track_counter_conditionals)
      class_eval do
        before_update :track_counter_conditionals
        def track_counter_conditionals
          _previous_conditionals = {}
          _counter_caches.each do |name, options|
            next unless options.has_key?(:conditional)
            _previous_conditionals[name] = eval_counter_condition(options)
          end
        end
      end
    end

    def create_update_counters_callback
      return if respond_to?(:update_counters)
      class_eval do
        after_update :update_counters
        def update_counters
          _counter_caches.each do |name, options|
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
          _counter_caches.each do |name, options|
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
          _counter_caches.each do |name, options|
            next unless eval_counter_condition(options)
            update_association_counter(name, options[:column], -1)
          end
        end
      end
    end

    def create_counter_callbacks_if_missing
      create_increment_counter_callback
      create_decrement_counter_callback
      create_update_counters_callback
    end

    def counter_cache(name, options={})
      options[:column] = (name + '_count').to_sym unless options.has_key?(:column)
      _counter_caches[name] = options
      create_counter_callbacks_if_missing
    end
  end
end
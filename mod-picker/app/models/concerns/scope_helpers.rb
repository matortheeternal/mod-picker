module ScopeHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def game_scope(options={})
      if options[:parent]
        class_eval do
          scope :game, -> (game_id) {
            game = Game.find(game_id)
            if game.parent_game_id.present?
              where(game_id: [game.id, game.parent_game_id])
            else
              where(game_id: game.id)
            end
          }
        end
      else
        class_eval do
          scope :game, -> (game_id) { where(game_id: game_id) }
        end
      end
    end

    def visible_scope(options={})
      if options[:approvable]
        class_eval do
          scope :visible, -> { where(hidden: false, approved: true) }
        end
      else
        class_eval do
          scope :visible, -> { where(hidden: false) }
        end
      end
    end

    def include_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || 'include_' + attribute.to_s
        value = options.has_key?(:value) ? options[:value] : 'false'
        class_eval do
          scope scope_name.to_sym, -> (bool) { where(attribute => value) if !bool }
        end
      end
    end

    def value_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || attribute.to_s.remove('is_')
        if options[:association]
          table_name = options[:table] || options[:association].to_s.pluralize
          class_eval do
            scope scope_name.to_sym, -> (value) { eager_load(options[:association]).
              where(table_name => {attribute => value}) }
          end
        else
          class_eval do
            scope scope_name.to_sym, -> (value) { where(attribute => value) }
          end
        end
      end
    end

    def nil_scope(attribute, **options)
      scope_name = options[:alias] || "nil_#{attribute.to_s}"
      class_eval do
        scope scope_name.to_sym, -> { where(attribute => nil) }
      end
    end

    def columns_in(columns, ids, connector=:or)
      columns.map{ |column|
        arel_table[column].in(ids)
      }.inject(connector)
    end

    def ids_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = attribute.to_s.remove('_id')
        if options[:columns]
          class_eval do
            scope scope_name.to_sym, -> (ids) {
              where(columns_in(options[:columns], ids))
            }
            scope scope_name.pluralize.to_sym, -> (ids) {
              where(columns_in(options[:columns], ids, :and))
            }
          end
        else
          class_eval do
            scope scope_name.pluralize.to_sym, -> (ids) { where(attribute => ids) }
          end
        end
      end
    end

    def user_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || attribute
        class_eval do
          scope scope_name.to_sym, -> (username) {
            includes(attribute).where(:users => {:username => username})
          }
        end
      end
    end

    def range_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || attribute
        if options[:association]
          table_name = options[:table] || options[:association].to_s.pluralize
          class_eval do
          scope scope_name.to_sym, -> (range) { includes(options[:association]).
            where(table_name => {attribute => (range[:min]..range[:max])}) }
          end
        else
          class_eval do
          scope scope_name.to_sym, -> (range) {
            where(attribute => (range[:min]..range[:max]))
          }
          end
        end
      end
    end

    def counter_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = attribute.to_s.remove('_count')
        range_scope attribute, :alias => scope_name
      end
    end

    def eval_enum_key(plural_attribute, key)
      key == "nil" ? nil : public_send(plural_attribute)[key]
    end

    def enum_scope(*attributes, **options)
      attributes.each do |attribute|
        plural_attribute = attribute.to_s.pluralize
        class_eval do
          scope attribute.to_sym, -> (values) {
            if values.is_a?(Hash)
              array = []
              values.each_key{ |key|
                array.push(eval_enum_key(plural_attribute, key)) if values[key]
              }
            else
              array = values
            end
            where(attribute => array)
          }
        end
      end
    end

    def hash_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || attribute.to_s.pluralize
        column_name = options[:column] || attribute
        class_eval do
          scope scope_name.to_sym, -> (hash) {
            array = []
            hash.each_key{ |key| array.push(key) if hash[key] }
            if options.has_key?(:table)
              where("#{options[:table]}.#{column_name} IN (?)", array)
            else
              where(column_name => array)
            end
          }
        end
      end
    end

    def polymorphic_scope(attribute, **options)
      plural_attribute = attribute.to_s.pluralize
      type_attribute = attribute.to_s + '_type'
      id_attribute = attribute.to_s + '_id'
      hash_scope attribute, :column => type_attribute, :alias => attribute
      class_eval do
        scope plural_attribute.to_sym, -> (polymorphic_type, ids) {
          where(type_attribute => polymorphic_type, id_attribute => ids)
        }
      end
    end

    def bytes_scope(*attributes, **options)
      attributes.each do |attribute|
        class_eval do
          scope attribute.to_sym, -> (range) {
            where(attribute => parse_bytes(range[:min])..parse_bytes(range[:max]))
          }
        end
      end
    end

    def date_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || attribute
        class_eval do
          scope scope_name.to_sym, -> (range) {
            where(attribute => parse_date(range[:min])..parse_date(range[:max]))
          }
        end
      end
    end

    def relational_division_query(joins_array, search_key, search_array)
      query = where(nil)
      search_array.each_with_index do |search, i|
        joins_array.each { |j|
          j[:table] = j[:class_name].safe_constantize.arel_table.alias("#{j[:class_name]}_#{i}")
        }
        prev_hash = { table: arel_table, joinable_on: :id }

        join_query = joins_array.inject(arel_table) do |join_relation, table_join_hash|
          join_relation = join_relation.join(table_join_hash[:table]).
              on(prev_hash[:table][prev_hash[:joinable_on]].
                  eq(table_join_hash[:table][table_join_hash[:join_on]]))
          prev_hash = table_join_hash
          join_relation
        end

        query = query.joins(join_query.join_sources).where(prev_hash[:table][search_key].eq(search))
      end

      query
    end

    def relational_division_scope(attribute, key, joins_array)
      class_eval do
        scope attribute.to_sym, -> (values) {
          relational_division_query(joins_array, key, values)
        }
      end
    end
  end
end
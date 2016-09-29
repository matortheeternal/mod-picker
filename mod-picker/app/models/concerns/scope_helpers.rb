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
        value = options[:value] || 'false'
        class_eval do
          scope scope_name.to_sym, -> (bool) { where(attribute => value) if !bool }
        end
      end
    end

    def value_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] ||attribute.to_s.remove('is_')
        if options[:association]
          table_name = options[:table] || options[:association].to_s.pluralize
          class_eval do
            scope scope_name.to_sym, -> (value) { includes(options[:association]).
              where(table_name => {attribute => value}) }
          end
        else
          class_eval do
            scope scope_name.to_sym, -> (value) { where(attribute => value) }
          end
        end
      end
    end

    def ids_scope(*attributes, **options)
      attributes.each do |attribute|
        if options[:columns]
          scope_name = attribute.to_s.remove('_id')
          scope_wheres = []
          options[:columns].each do |column|
            scope_wheres.push("#{column} IN (:ids)")
          end
          class_eval do
            scope scope_name.to_sym, -> (ids) {
              where("#{scope_wheres.join(' OR ')}", ids: ids)
            }
            scope scope_name.pluralize.to_sym, -> (ids) {
              where("#{scope_wheres.join(' AND ')}", ids: ids)
            }
          end
        else
          scope_name = attribute.to_s.remove('_id').pluralize
          class_eval do
            scope scope_name.to_sym, -> (ids) { where(attribute => ids) }
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

    def search_scope(*attributes, **options)
      if options[:combine]
        class_eval do
            scope :search, -> (search) {
              where(attributes.map{|attribute| arel_table[attribute.to_sym].matches("%#{search}%") }.inject(:or))
            }
        end
      else
        attributes.each do |attribute|
          scope_name = options[:alias] || attribute
          class_eval do
            scope scope_name.to_sym, -> (search) {
              where(arel_table[attribute.to_sym].matches("%#{search}%"))
            }
          end
        end
      end
    end

    def enum_scope(*attributes, **options)
      attributes.each do |attribute|
        plural_attribute = attribute.to_s.pluralize
        class_eval <<-buildscope
          scope :#{attribute}, -> (values) {
            if values.is_a?(Hash)
              array = []
              values.each_key{ |key| array.push(#{plural_attribute}[key]) if values[key] }
            else
              array = values
            end
            where(#{attribute}: array)
          }
        buildscope
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
            where(column_name => array)
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
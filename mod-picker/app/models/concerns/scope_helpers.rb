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
        class_eval <<-buildscope
          scope :#{scope_name}, -> (bool) { where(#{attribute}: #{value}) if !bool }
        buildscope
      end
    end

    def value_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] ||attribute.to_s.remove('is_')
        if options[:association]
          table_name = options[:table] || options[:association].to_s.pluralize
          class_eval <<-buildscope
            scope :#{scope_name}, -> (value) { joins(:#{options[:association]}).
              where(#{table_name}: {#{attribute}: value}) }
          buildscope
        else
          class_eval <<-buildscope
            scope :#{scope_name}, -> (value) { where(#{attribute}: value) }
          buildscope
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
          class_eval <<-buildscope
            scope :#{scope_name}, -> (ids) {
              where("#{scope_wheres.join(' OR ')}", ids: ids)
            }
            scope :#{scope_name.pluralize}, -> (ids) {
              where("#{scope_wheres.join(' AND ')}", ids: ids)
            }
          buildscope
        else
          scope_name = attribute.to_s.remove('_id').pluralize
          class_eval <<-buildscope
            scope :#{scope_name}, -> (ids) { where(#{attribute}: ids) }
          buildscope
        end
      end
    end

    def user_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || attribute
        class_eval <<-buildscope
          scope :#{scope_name}, -> (username) { joins(#{attribute}).where(:users => {:username => username}) }
        buildscope
      end
    end

    def range_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || attribute
        # TODO: Rename these scopes maybe?
        if options[:association]
          table_name = options[:table] || options[:association].to_s.pluralize
          class_eval <<-buildscope
          scope :#{scope_name}, -> (range) { joins(#{options[:associations]}).
            where(#{table_name}: {#{attribute} => (range[:min]..range[:max])}) }
          buildscope
        else
          class_eval <<-buildscope
          scope :#{scope_name}, -> (range) { where(#{attribute}: (range[:min]..range[:max])) }
          buildscope
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
        search_terms = []
        attributes.each { |attribute| search_terms.push("#{attribute} like :search")}
        class_eval <<-buildscope
            scope :search, -> (search) { where("#{search_terms.join(' OR ')}", search: "%#\{search\}%") }
        buildscope
      else
        attributes.each do |attribute|
          scope_name = options[:alias] || attribute
          class_eval <<-buildscope
            scope :#{scope_name}, -> (search) { where("#{attribute} like ?", "%#\{search\}%") }
          buildscope
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
        column_name = options[:column] || attribute
        class_eval <<-buildscope
          scope :#{attribute}, -> (hash) {
            array = []
            hash.each_key{ |key| array.push(key) if hash[key] }
            where(#{column_name}: array)
          }
        buildscope
      end
    end

    def polymorphic_scope(attribute, **options)
      plural_attribute = attribute.to_s.pluralize
      type_attribute = attribute.to_s + '_type'
      id_attribute = attribute.to_s + '_id'
      hash_scope attribute, :column => type_attribute
      class_eval <<-buildscope
        scope :#{plural_attribute}, -> (polymorphic_type, ids) {
          where(#{type_attribute}: polymorphic_type, #{id_attribute}: ids)
        }
      buildscope
    end

    def bytes_scope(*attributes, **options)
      attributes.each do |attribute|
        class_eval <<-buildscope
          scope :#{attribute}, -> (range) { where(#{attribute}: parse_bytes(range[:min])..parse_bytes(range[:max])) }
        buildscope
      end
    end

    def date_scope(*attributes, **options)
      attributes.each do |attribute|
        scope_name = options[:alias] || attribute
        class_eval <<-buildscope
          scope :#{scope_name}, -> (range) { where(#{attribute}: parse_date(range[:min])..parse_date(range[:max])) }
        buildscope
      end
    end
  end
end
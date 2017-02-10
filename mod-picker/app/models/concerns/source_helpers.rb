module SourceHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def get_source_class(source_key)
      {
          nexus: NexusInfo,
          lab: LoverInfo,
          workshop: WorkshopInfo,
          other: CustomSource
      }.with_indifferent_access[source_key]
    end

    def get_source_primary_key_column(source_key)
      source_key.to_sym == :nexus ? :nexus_id : :id
    end

    def source_search_scope(attribute, options={})
      class_eval do
          scope attribute, -> (search) {
            sources = search[:sources]
            where(sources.map { |source|
              get_source_class(source).arel_table[attribute.to_sym].matches("%#{search[:value]}%")
            }.inject(:or))
          }
      end
    end

    def source_scope(attribute, options={})
      class_eval do
        scope attribute, -> (range) {
          sources = range[:sources]
          where(sources.map.with_index { |source, index|
            column = options[:alias] ? options[:alias][index] : attribute
            get_source_class(source).arel_table[column.to_sym].in(range[:min]..range[:max])
          }.inject(:or))
        }
      end
    end
  end
end
module SourceHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def get_source_table(source_key)
      case source_key
        when :nexus
          return :nexus_infos
        when :lab
          return :lover_infos
        when :workshop
          return :workshop_infos
        else
          raise("Invalid source key!")
      end
    end

    def source_scope(attribute, options={})
      # single site scope
      if options[:sites].length == 1
        column = attribute || options[:alias][0]
        source_table = get_source_table(options[:sites][0])
        class_eval <<-buildscope
          scope :#{attribute}, -> (range) {
            where(:#{source_table} => {#{column}: (range[:min]..range[:max])}) }
        buildscope
      else
        scope_wheres = []
        options[:sites].each_with_index do |site,index|
          source_table = get_source_table(site)
          column_name = options[:alias] ? options[:alias][index] : attribute
          scope_wheres.push("results = results.where(:#{source_table} => { #{column_name}: (range[:min]..range[:max]) }) if sources[:#{site}]")
        end
        class_eval <<-buildscope
          scope :#{attribute}, -> (range) {
            sources = range[:sources]

            results = self.where(nil)
            #{scope_wheres.join("\n")}
            results
          }
        buildscope
      end
    end
  end
end
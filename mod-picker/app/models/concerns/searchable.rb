require 'arel-helpers'

module Searchable
  extend ActiveSupport::Concern

  included do
    class_attribute :_search_options
    scope :search, -> (search) {
      where(build_search_queries(search).map{ |q| arel_search(q) }.inject(:or))
    }
  end

  module ClassMethods
    def get_search_terms(search)
      # matches each separate search term delimited by whitespace
      # "quoted strings" are treated as single search terms
      # text_followed_by_a_colon:"with quoted text afterwards"
      # is also treated as a single search term
      search.scan(/(?:"[^"]*"|[^\:\s]+\:"[^"]*"|[^\s]+)+/)
    end

    def nil_if_blank(a)
      a.blank? ? nil : a
    end

    def unquote(s, quoteChar='"')
      s[0] == quoteChar && s[-1] == quoteChar ? s[1..-2] : s
    end

    def option_terms(option_label, search_terms)
      search_terms.
          select { |term| term.starts_with?(option_label) }.
          map { |term| unquote(term.sub(option_label, "")) }
    end

    def general_terms(search_terms)
      search_terms.
          select { |term| /([^\:\s]+\:("[^"]*"|[^\s]+))/.match(term).nil? }.
          map { |term| unquote(term) }
    end

    def matching_terms(option, search_terms)
      nil_if_blank(option_terms("#{option[:alias] || option[:column]}:", search_terms)) || general_terms(search_terms)
    end

    def build_search_queries(search)
      search_terms = get_search_terms(search)
      search_options.clone.
          each { |option| option[:search] = matching_terms(option, search_terms) }.
          select { |option| option[:search].present? }
    end

    def multi_arel_search(query)
      query[:subqueries].map { |subquery|
        subquery[:search] = query[:search]
        arel_search(subquery)
      }.inject(:or)
    end

    def get_query_table(query)
      if query.has_key?(:table_alias)
        query[:model].safe_constantize.arel_table.alias(query[:table_alias])
      else
        query[:model].safe_constantize.arel_table
      end
    end

    def association_arel_search(query)
      column = get_query_table(query)[query[:column].to_sym]
      query[:search].map { |term| column.matches("%#{term}%") }.inject(:and)
    end

    def basic_arel_search(query)
      column = arel_table[query[:column].to_sym]
      query[:search].map { |term| column.matches("%#{term}%") }.inject(:and)
    end

    def arel_search(query)
      return multi_arel_search(query) if query.has_key?(:subqueries)
      return association_arel_search(query) if query.has_key?(:model)
      basic_arel_search(query)
    end

    def search_options_path
      Rails.root.join('app', 'models', 'search_options', "#{name.underscore.pluralize}.json")
    end

    def load_search_options
      file_path = search_options_path
      return [] unless File.exists?(file_path)
      JSON.parse(File.read(file_path), symbolize_names: true)
    end

    def search_options
      _search_options ||= load_search_options
    end
  end
end
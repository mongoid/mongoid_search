module Mongoid::Search
  extend ActiveSupport::Concern

  included do
    cattr_accessor :search_fields
    @@classes ||= []
    @@classes << self
  end

  def self.classes
    @@classes
  end

  module ClassMethods #:nodoc:
    # Set a field or a number of fields as sources for search
    def search_in(*args)
      args, options = args_and_options(args)
      set_search_fields(options[:index], args)

      field options[:index], type: Array

      index({ options[:index] => 1 }, background: true)

      before_save :set_keywords
    end

    def full_text_search(query, options = {})
      options = extract_options(options)
      attr_accessor :relevance if options[:relevant_search].eql? true

      return (options[:allow_empty_search] ? criteria.all : []) if query.blank?

      if options[:relevant_search]
        search_relevant(query, options)
      else
        search_without_relevance(query, options)
      end
    end

    # Keeping these aliases for compatibility purposes
    alias csearch full_text_search
    alias search full_text_search

    # Goes through all documents in the class that includes Mongoid::Search
    # and indexes the keywords.
    def index_keywords!
      all.each { |d| d.index_keywords! ? Log.green('.') : Log.red('F') }
    end

    private

    def set_search_fields(index, fields)
      self.search_fields ||= {}

      (self.search_fields[index] ||= []).concat fields
    end

    def query(keywords, options)
      keywords_hash = keywords.map do |kw|
        if Mongoid::Search.regex_search
          escaped_kw = Regexp.escape(kw)
          kw = Mongoid::Search.regex.call(escaped_kw)
        end

        { options[:index] => kw }
      end

      criteria.send("#{(options[:match])}_of", *keywords_hash)
    end

    def args_and_options(args)
      options = args.last.is_a?(Hash) &&
        %i[match
           allow_empty_search
           index
           relevant_search].include?(args.last.keys.first) ? args.pop : {}

      [args, extract_options(options)]
    end

    def extract_options(options)
      {
        match: options[:match] || Mongoid::Search.match,
        allow_empty_search: options[:allow_empty_search] || Mongoid::Search.allow_empty_search,
        relevant_search: options[:relevant_search] || Mongoid::Search.relevant_search,
        index: options[:index] || :_keywords
      }
    end

    def search_without_relevance(query, options)
      query(Util.normalize_keywords(query), options)
    end

    def search_relevant(query, options)
      results_with_relevance(query, options) { |o| o['value'] }.map do |r|
        new(r['_id'].merge(relevance: r['value'])) do |o|
          # Need to match the actual object
          o.instance_variable_set('@new_record', false)
          o._id = r['_id']['_id']
        end
      end
    end

    def results_with_relevance(query, options)
      keywords = Mongoid::Search::Util.normalize_keywords(query)

      map = %{
          function() {
            var entries = 0;
            for(i in keywords) {
              for(j in this.#{options[:index]}) {
                if(this.#{options[:index]}[j] == keywords[i]) {
                  entries++;
                }
              }
            }
            if(entries > 0) {
              emit(this, entries);
            }
          }
      }

      reduce = %{
          function(key, values) {
            return(values);
          }
      }

      query(keywords, options).map_reduce(map, reduce).scope(keywords: keywords).out(inline: 1)
    end
  end

  def index_keywords!
    search_fields.map do |index, fields|
      update_attribute(index, get_keywords(fields))
    end
  end

  def set_keywords
    search_fields.each do |index, fields|
      send("#{index}=", get_keywords(fields))
    end
  end

  def get_keywords(fields)
    Mongoid::Search::Util.keywords(self, fields)
                         .flatten.reject { |k| k.nil? || k.empty? }.uniq.sort
  end
end

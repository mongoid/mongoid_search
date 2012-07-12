module Mongoid::Search
  def self.included(base)
    base.send(:cattr_accessor, :search_fields)

    base.extend ClassMethods

    @@classes ||= []
    @@classes << base
  end

  def self.classes
    @@classes
  end

  module ClassMethods #:nodoc:
    # Set a field or a number of fields as sources for search
    def search_in(*args)
      args, options = args_and_options(args)
      self.search_fields = (self.search_fields || []).concat args

      field :_keywords, :type => Array

      index({ :_keywords => 1 }, { :background => true })

      before_save :set_keywords
    end

    def full_text_search(query, options={})
      options = extract_options(options)
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
      all.each { |d| d.index_keywords! ? Log.green(".") : Log.red("F") }
    end

    private
    def query(keywords, options)
      keywords_hash = keywords.map do |kw|
        kw = Mongoid::Search.regex.call(kw) if Mongoid::Search.regex_search
        { :_keywords => kw }
      end

      criteria.send("#{(options[:match]).to_s}_of", *keywords_hash)
    end

    def args_and_options(args)
      options = args.last.is_a?(Hash) &&
                [:match,
                 :allow_empty_search,
                 :relevant_search].include?(args.last.keys.first) ? args.pop : {}

      [args, extract_options(options)]
    end

    def extract_options(options)
      {
        :match              => options[:match]              || Mongoid::Search.match,
        :allow_empty_search => options[:allow_empty_search] || Mongoid::Search.allow_empty_search,
        :relevant_search    => options[:relevant_search]    || Mongoid::Search.relevant_search
      }
    end

    def search_without_relevance(query, options)
      query(Util.normalize_keywords(query), options)
    end

    def search_relevant(query, options)
      results_with_relevance(query, options).sort { |o| o['value'] }.map do |r|

        new(r['_id'].merge(:relevance => r['value'])) do |o|
          # Need to match the actual object
          o.instance_variable_set('@new_record', false)
          o._id = r['_id']['_id']
        end

      end
    end

    def results_with_relevance(query, options)
      keywords = Util.normalize_keywords(query)

      map = %Q{
        function() {
          var entries = 0;
          for(i in keywords) {
            for(j in this._keywords) {
              if(this._keywords[j] == keywords[i]) {
                entries++;
              }
            }
          }
          if(entries > 0) {
            emit(this, entries);
          }
        }
      }

      reduce = %Q{
        function(key, values) {
          return(values);
        }
      }

      query(keywords, options).map_reduce(map, reduce).scope(:keywords => keywords).out(:inline => 1)
    end
  end

  def index_keywords!
    update_attribute(:_keywords, set_keywords)
  end

  private
  def set_keywords
    self._keywords = self.search_fields.map do |field|
      Util.keywords(self, field)
    end.flatten.reject{|k| k.nil? || k.empty?}.uniq.sort
  end
end

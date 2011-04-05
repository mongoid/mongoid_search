module Mongoid::Search
  extend ActiveSupport::Concern

  included do
    cattr_accessor :search_fields, :match, :allow_empty_search, :relevant_search, :stem_keywords, :ignore_list
  end

  module ClassMethods #:nodoc:
    # Set a field or a number of fields as sources for search
    def search_in(*args)
      options = args.last.is_a?(Hash) && [:match, :allow_empty_search, :relevant_search, :stem_keywords, :ignore_list].include?(args.last.keys.first) ? args.pop : {}
      self.match              = [:any, :all].include?(options[:match]) ? options[:match] : :any
      self.allow_empty_search = [true, false].include?(options[:allow_empty_search]) ? options[:allow_empty_search] : false
      self.relevant_search    = [true, false].include?(options[:relevant_search]) ? options[:allow_empty_search] : false
      self.stem_keywords      = [true, false].include?(options[:stem_keywords]) ? options[:allow_empty_search] : false
      self.ignore_list        = YAML.load(File.open(options[:ignore_list]))["ignorelist"] if options[:ignore_list].present?
      self.search_fields      = args

      field :_keywords, :type => Array
      index :_keywords

      before_save :set_keywords
    end

    def search(query, options={})
      if relevant_search
        search_relevant(query, options)
      else
        search_without_relevance(query, options)
      end
    end

    def search_without_relevance(query, options={})
      return self.all if query.blank? && allow_empty_search
      self.send("#{(options[:match]||self.match).to_s}_in", :_keywords => Util.keywords(query, stem_keywords, ignore_list).map { |q| /#{q}/ })
    end

    def search_relevant(query, options={})
      return self.all if query.blank? && allow_empty_search

      keywords = Util.keywords(query, stem_keywords, ignore_list)

      map = <<-EOS
        function() {
          var entries = 0
          for(i in keywords)
            for(j in this._keywords) {
              if(this._keywords[j] == keywords[i])
                entries++
            }
          if(entries > 0)
            emit(this._id, entries)
        }
      EOS
      reduce = <<-EOS
        function(key, values) {
          return(values[0])
        }
      EOS

      #raise [self.class, self.inspect].inspect

      kw_conditions = keywords.map do |kw|
        {:_keywords => kw}
      end

      criteria = self.any_of(*kw_conditions)

      query = criteria.selector

      options.delete(:limit)
      options.delete(:skip)
      options.merge! :scope => {:keywords => keywords}, :query => query

      res = collection.map_reduce(map, reduce, options)

      res.find.sort(['value', -1]) # Cursor
    end
  end

  private

  # TODO: This need some refatoring..
  def set_keywords
    self._keywords = self.search_fields.map do |field|
      if field.is_a?(Hash)
        field.keys.map do |key|
          attribute = self.send(key)
          method = field[key]
          if attribute.is_a?(Array)
            if method.is_a?(Array)
              method.map {|m| attribute.map { |a| Util.keywords a.send(m), stem_keywords, ignore_list } }
            else
              attribute.map(&method).map { |t| Util.keywords t, stem_keywords, ignore_list }
            end
          else
            Util.keywords(attribute.send(method), stem_keywords, ignore_list)
          end
        end
      else
        text = self[field]
        Util.keywords(text, stem_keywords, ignore_list) unless text.nil?
      end
    end.flatten.compact.sort
  end
end

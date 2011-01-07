module Mongoid::Search
  extend ActiveSupport::Concern
  
  included do
    cattr_accessor :search_fields, :match, :allow_empty_search
  end
  
  module ClassMethods #:nodoc:
    # Set a field or a number of fields as sources for search
    def search_in(*args)
      options = args.last.is_a?(Hash) && (args.last.keys.first == :match || args.last.keys.first == :allow_empty_search) ? args.pop : {}
      self.match = [:any, :all].include?(options[:match]) ? options[:match] : :any
      self.allow_empty_search = [true, false].include?(options[:allow_empty_search]) ? options[:allow_empty_search] : false
      self.search_fields = args

      field :_keywords, :type => Array
      index :_keywords
      
      before_save :set_keywords
    end
    
    def search(query, options={})
      return self.all if query.blank? && allow_empty_search
      self.send("#{(options[:match]||self.match).to_s}_in", :_keywords => KeywordsExtractor.extract(query).map { |q| /#{q}/ })
    end
    
    def search_relevant(query, options={})
      return self.all if query.blank? && allow_empty_search
      
      keywords = KeywordsExtractor.extract(query)
      
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
      
      query = if scope_stack.count > 0
        scope_stack.inject{|a, b| a + b}.selector
      end

      limit = options.delete(:limit)
      options.merge! :scope => {:keywords => keywords}, :query => query
                     
      cursor = collection.map_reduce(map, reduce, options).find.sort(['value', -1])
      cursor = cursor.limit(limit) if limit
      cursor
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
              method.map {|m| attribute.map { |a| KeywordsExtractor.extract a.send(m) } }
            else
              attribute.map(&method).map { |t| KeywordsExtractor.extract t }
            end
          else
            KeywordsExtractor.extract(attribute.send(method))
          end
        end
      else
        KeywordsExtractor.extract(self.send(field))
      end
    end.flatten.compact.uniq.sort
  end
end
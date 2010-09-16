module Mongoid::Search
  extend ActiveSupport::Concern
  
  included do
    cattr_accessor :search_fields, :match
  end
  
  module ClassMethods #:nodoc:
    # Set a field or a number of fields as sources for search
    def search_in(*args)
      options = args.last.is_a?(Hash) ? args.pop : {}
      self.match = options[:match] || :any
      self.search_fields = args

      field :_keywords, :type => Array
      index :_keywords
      
      before_save :set_keywords
    end
    
    def search(query)
      self.send("#{self.match.to_s}_in", :_keywords => keywords(query).map { |q| /#{q}/i })
    end
    
    private
    def set_keywords
      self._keywords = []
      self.search_fields.each do |field| 
        self._keywords << field.is_a?(Hash) ? self.send(field.keys.first).map(&field.values.first) : keywords(self.send(field))
      end
      self._keywords = self._keywords.flatten.uniq
    end
    
    def keywords(text)
      text.mb_chars.normalize(:kd).to_s.gsub(/[^\x00-\x7F]/,'').downcase.split(/[\s\.\-_]+/)
    end
  end
end
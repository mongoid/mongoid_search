module Mongoid::Search
  extend ActiveSupport::Concern
  
  included do
    cattr_accessor :search_fields, :match
  end
  
  module ClassMethods #:nodoc:
    # Set a field or a number of fields as sources for search
    def search_in(*args)
      options = args.last.is_a?(Hash) && (args.last.keys.first == :match) ? args.pop : {}
      self.match = [:any, :all].include?(options[:match]) ? options[:match] : :any
      self.search_fields = args

      field :_keywords, :type => Array
      index :_keywords
      
      before_save :set_keywords
    end
    
    def search(query)
      self.send("#{self.match.to_s}_in", :_keywords => KeywordsExtractor.extract(query).map { |q| /#{q}/ })
    end
  end
  
  private
  
  def set_keywords
    self._keywords = self.search_fields.map do |field|
      if field.is_a?(Hash)
        field.keys.map { |key| self.send(key).map(&field[key]).map { |t| KeywordsExtractor.extract t } }
      else
        KeywordsExtractor.extract(self.send(field))
      end
    end.flatten.compact.uniq
  end
end
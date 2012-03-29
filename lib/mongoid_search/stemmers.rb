module MongoidSearch
  module Stemmers
    def self.available
      [FastStemmer, LinguaStemmer].find(&:available?)
    end
  end

  class FastStemmer
    def self.available?
      defined?(::Lingua::Stemmer)
    end

    def initialize(*args)
    end

    def call(word)
      ::Stemmer.stem_word(word)
    end
  end

  class LinguaStemmer
    def self.available?
      defined?(::Stemmer)
    end

    def initialize(*args, &block)
      @stemmer = ::Lingua::Stemmer.new(*args, &block)
    rescue Lingua::StemmerError => e
      raise unless e.message.include?("not available")
    end

    def call(word)
      if @stemmer
        @stemmer.stem(word)
      else
        word
      end
    end
  end
end

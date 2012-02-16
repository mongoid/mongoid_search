module MongoidSearch
  module Stemmers
    def self.available
      if defined?(::Stemmer)
        FastStemmer
      elsif defined?(::Lingua::Stemmer)
        LinguaStemmer
      end
    end
  end

  class FastStemmer
    def initialize(*args)
    end

    def call(word)
      ::Stemmer.stem_word(word)
    end
  end

  class LinguaStemmer
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

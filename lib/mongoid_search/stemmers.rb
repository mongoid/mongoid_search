module MongoidSearch
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
    end

    def call(word)
      @stemmer.stem(word)
    end
  end
end

module MongoidSearch
  module Util

    def self.keywords(klass, field, stemmer, ignore_list)
      if field.is_a?(Hash)
        field.keys.map do |key|
          attribute = klass.send(key)
          unless attribute.blank?
            method = field[key]
            if attribute.is_a?(Array)
              if method.is_a?(Array)
                method.map {|m| attribute.map { |a| Util.normalize_keywords a.send(m), stemmer, ignore_list } }
              else
                attribute.map(&method).map { |t| Util.normalize_keywords t, stemmer, ignore_list }
              end
            else
              Util.normalize_keywords(attribute.send(method), stemmer, ignore_list)
            end
          end
        end
      else
        value = klass[field]
        value = value.join(' ') if value.respond_to?(:join)
        Util.normalize_keywords(value, stemmer, ignore_list) if value
      end
    end

    def self.normalize_keywords(text, stemmer, ignore_list)
      return [] if text.blank?
      text = text.to_s.
        mb_chars.
        normalize(:kd).
        downcase.
        to_s.
        gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]]/, ' '). # strip punctuation
        gsub(/[^[:alnum:]\s]/,'').   # strip accents
        split(' ').
        reject { |word| word.size < 2 }
      text = text.reject { |word| ignore_list.include?(word) } unless ignore_list.blank?
      text = text.map{ |word| stemmer.call(word) } if stemmer
      text
    end

  end
end

# encoding: utf-8
module Util

  def self.keywords(klass, field)
    if field.is_a?(Hash)
      field.keys.map do |key|
        attribute = klass.send(key)
        unless attribute.blank?
          method = field[key]
          if attribute.is_a?(Array)
            if method.is_a?(Array)
              method.map {|m| attribute.map { |a| Util.normalize_keywords a.send(m) } }
            else
              attribute.map(&method).map { |t| Util.normalize_keywords t }
            end
          elsif attribute.is_a?(Hash)
            if method.is_a?(Array)
              method.map {|m| Util.normalize_keywords attribute[m.to_sym] }
            else
              Util.normalize_keywords(attribute[method.to_sym])
            end
          else
            Util.normalize_keywords(attribute.send(method))
          end
        end
      end
    else
      value = klass[field]
      value = value.join(' ') if value.respond_to?(:join)
      Util.normalize_keywords(value) if value
    end
  end

  def self.normalize_keywords(text)
    ligatures     = Mongoid::Search.ligatures
    ignore_list   = Mongoid::Search.ignore_list
    stem_keywords = Mongoid::Search.stem_keywords

    return [] if text.blank?
    text = text.to_s.
      mb_chars.
      normalize(:kd).
      downcase.
      to_s.
      gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]]/, ' '). # strip punctuation
      gsub(/[^[:alnum:]\s]/,'').   # strip accents
      gsub(/[#{ligatures.keys.join("")}]/) {|c| ligatures[c]}.
      split(' ').
      reject { |word| word.size < Mongoid::Search.minimum_word_size }
    text = text.reject { |word| ignore_list.include?(word) } unless ignore_list.blank?
    text = text.map(&:stem) if stem_keywords
    text
  end

end

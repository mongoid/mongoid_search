module Util

  def self.keywords(klass, field, stem_keywords, ignore_list)
    if field.is_a?(Hash)
      field.keys.map do |key|
        attribute = klass.send(key)
        unless attribute.blank?
          method = field[key]
          if attribute.is_a?(Array)
            if method.is_a?(Array)
              method.map {|m| attribute.map { |a| Util.normalize_keywords a.send(m), stem_keywords, ignore_list } }
            else
              attribute.map(&method).map { |t| Util.normalize_keywords t, stem_keywords, ignore_list }
            end
          else
            Util.normalize_keywords(attribute.send(method), stem_keywords, ignore_list)
          end
        end
      end
    else
      value = klass[field]
      value = value.join(' ') if value.respond_to?(:join)
      Util.normalize_keywords(value, stem_keywords, ignore_list) if value
    end
  end

  def self.normalize_keywords(text, stem_keywords, ignore_list)
    return [] if text.blank?
    text = text.to_s.
      mb_chars.
      normalize(:kd).
      to_s.
      gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]]/, ' '). # strip punctuation
      gsub(/[^[:alnum:]\s]/,'').   # strip accents
      downcase.
      split(' ').
      reject { |word| word.size < 2 }
    text = text.reject { |word| ignore_list.include?(word) } unless ignore_list.blank?
    text = text.map(&:stem) if stem_keywords
    text
  end

end

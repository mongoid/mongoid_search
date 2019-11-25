
module Mongoid::Search::Util
  def self.keywords(klass, fields)
    if fields.is_a?(Array)
      fields.map do |field|
        keywords(klass, field)
      end
    elsif fields.is_a?(Hash)
      fields.keys.map do |field|
        attribute = klass.send(field)
        unless attribute.blank?
          if attribute.is_a?(Array)
            attribute.map { |a| keywords(a, fields[field]) }
          else
            keywords(attribute, fields[field])
          end
        end
      end
    else
      value = if klass.respond_to?(fields.to_s + '_translations')
                klass.send(fields.to_s + '_translations').values
              elsif klass.respond_to?(fields)
                klass.send(fields)
              else
                value = klass[fields]
              end
      value = value.join(' ') if value.respond_to?(:join)
      normalize_keywords(value) if value
    end
  end

  def self.normalize_keywords(text)
    ligatures     = Mongoid::Search.ligatures
    ignore_list   = Mongoid::Search.ignore_list
    stem_keywords = Mongoid::Search.stem_keywords
    stem_proc     = Mongoid::Search.stem_proc
    strip_symbols = Mongoid::Search.strip_symbols
    strip_accents = Mongoid::Search.strip_accents

    return [] if text.blank?
    text = text.to_s
               .mb_chars
               .unicode_normalize(:nfkd)
               .downcase
               .to_s
               .gsub(strip_symbols, ' ') # strip symbols
               .gsub(strip_accents, '')  # strip accents
               .gsub(/[#{ligatures.keys.join("")}]/) { |c| ligatures[c] }
               .split(' ')
               .reject { |word| word.size < Mongoid::Search.minimum_word_size }
    text = text.reject { |word| ignore_list.include?(word) } unless ignore_list.blank?
    text = text.map(&stem_proc) if stem_keywords
    text
  end
end

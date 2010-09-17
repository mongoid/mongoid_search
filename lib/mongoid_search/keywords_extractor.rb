class KeywordsExtractor
  def self.extract(text)
    return if text.blank?
    text.mb_chars.normalize(:kd).to_s.gsub(/[^\x00-\x7F]/,'').downcase.split(/[\s\.\-_]+/)
  end
end
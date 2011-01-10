class KeywordsExtractor
  def self.extract(text)
    return [] if text.blank?
    text.mb_chars.normalize(:kd).to_s.gsub(/[^[:alpha:]\s\.\-_:;'",]/,'').downcase.split(/[\s\.\-_:;'",]+/)
  end
end
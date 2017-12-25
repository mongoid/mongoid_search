class Mongoid::Search::Log
  cattr_accessor :silent

  def self.log(message)
    print message unless silent
  end

  def self.red(text)
    log(colorize(text, 31))
  end

  def self.green(text)
    log(colorize(text, 32))
  end

  private

  def self.colorize(text, code)
    "\033[#{code}m#{text}\033[0m"
  end
end

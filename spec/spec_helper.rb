require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'mongoid'
require 'database_cleaner'
if RUBY_PLATFORM == 'java'
  require 'jruby-stemmer'
else
  require 'fast_stemmer'
end
require 'yaml'
require 'mongoid_search'

Mongoid.configure do |config|
  config.connect_to "mongoid_search_test"
end

Dir["#{File.dirname(__FILE__)}/models/*.rb"].each { |file| require file }

DatabaseCleaner.orm = :mongoid

RSpec.configure do |config|
  config.before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

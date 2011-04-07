require 'rubygems'
require 'rake'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = ["-c", "-f progress"]
  spec.pattern = 'spec/**/*_spec.rb'
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mongoid_search"
    gem.summary = "Search implementation for Mongoid ORM"
    gem.description = "Simple full text search implementation."
    gem.email = "mauricio@papodenerd.net"
    gem.homepage = "http://www.papodenerd.net/mongoid-search-full-text-search-for-your-mongoid-models/"
    gem.authors = ["Mauricio Zaffari"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


task :default => :spec

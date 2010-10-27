require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "mongoid_search"
    gem.summary = "Search implementation for Mongoid ORM"
    gem.description = "Simple full text search implementation."
    gem.email = "mauricio@papodenerd.net"
    gem.homepage = "http://www.papodenerd.net/mongoid-search-full-text-search-for-your-mongoid-models/"
    gem.authors = ["Mauricio Zaffari"]
    gem.add_dependency("mongoid", ["~> 2.0.0"])
    gem.add_development_dependency "rspec", ">= 2.0.1"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec

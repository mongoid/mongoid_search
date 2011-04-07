# encoding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name = "mongoid_search"
  s.version = "0.2.0"
  s.authors = ["Mauricio Zaffari"]
  s.email =["mauricio@papodenerd.net"]
  s.homepage = "http://www.papodenerd.net/mongoid-search-full-text-search-for-your-mongoid-models/"
  s.summary = "Search implementation for Mongoid ORM"
  s.description = "Simple full text search implementation."

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency("mongoid", ["~> 2.0.0"])
  s.add_dependency("bson_ext", ["~> 1.2"])
  s.add_dependency("fast-stemmer", ["~> 1.0.0"])

  s.add_development_dependency("jeweler", ["~> 1.4.0"])
  s.add_development_dependency("database_cleaner", ["~> 0.6.4"])
  s.add_development_dependency("rake", ["= 0.8.7"])
  s.add_development_dependency("rspec", ["~> 2.4"])

  s.require_path = "lib"
  s.files = Dir.glob("lib/**/*") + %w(LICENSE README.md Rakefile VERSION)
  s.test_files = Dir.glob("spec/**/*")
end

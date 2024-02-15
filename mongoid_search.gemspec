# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'mongoid_search'
  s.version = '0.5.0'
  s.authors = ['Mauricio Zaffari']
  s.email = ['mauricio@papodenerd.net']
  s.homepage = 'https://github.com/mongoid/mongoid_search'
  s.summary = 'Search implementation for Mongoid ORM'
  s.description = 'Simple full text search implementation.'
  s.license = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'
  s.required_ruby_version = '>= 2.7'

  s.platform = 'ruby'

  s.add_dependency('fast-stemmer', ['~> 1.0.0'])
  s.add_dependency('mongoid', ['>= 5.0.0'])
  s.add_development_dependency('database_cleaner-mongoid', ['>= 2.0.0'])
  s.add_development_dependency('mongoid-compatibility')
  s.add_development_dependency('rake', ['>= 12.3.3'])
  s.add_development_dependency('rspec', ['~> 3.1'])

  s.require_path = 'lib'
  s.files = Dir['lib/**/*', 'tasks/*.rake'] + %w[LICENSE README.md Rakefile]
  s.test_files = Dir.glob('spec/**/*')
end

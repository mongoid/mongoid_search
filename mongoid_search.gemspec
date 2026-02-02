# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'mongoid_search'
  s.version = '0.6.0'
  s.authors = ['Mauricio Zaffari']
  s.email = ['mauricio@papodenerd.net']
  s.homepage = 'https://github.com/mongoid/mongoid_search'
  s.summary = 'Search implementation for Mongoid ORM'
  s.description = 'Simple full text search implementation.'
  s.license = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'
  s.required_ruby_version = '>= 3.0'

  s.platform = 'ruby'

  s.add_dependency('fast-stemmer', ['~> 1.0.0'])
  s.add_dependency('mongoid', ['>= 6.0.0'])

  s.require_path = 'lib'
  s.files = Dir['lib/**/*', 'tasks/*.rake'] + %w[LICENSE README.md Rakefile]
  s.metadata['rubygems_mfa_required'] = 'true'
end

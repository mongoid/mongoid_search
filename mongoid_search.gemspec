
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = 'mongoid_search'
  s.version = '0.4.0'
  s.authors = ['Mauricio Zaffari']
  s.email = ['mauricio@papodenerd.net']
  s.homepage = 'https://github.com/mongoid/mongoid_search'
  s.summary = 'Search implementation for Mongoid ORM'
  s.description = 'Simple full text search implementation.'
  s.license = 'MIT'

  s.required_rubygems_version = '>= 1.3.6'

  s.platform = 'ruby'

  s.add_dependency('fast-stemmer', ['~> 1.0.0'])
  s.add_dependency('mongoid', ['>= 5.0.0'])
  s.add_development_dependency('database_cleaner', ['>= 0.8.0'])
  s.add_development_dependency('mongoid-compatibility')
  s.add_development_dependency('rake', ['>= 11.0'])
  s.add_development_dependency('rspec', ['~> 2.4'])

  s.require_path = 'lib'
  s.files = Dir['lib/**/*', 'tasks/*.rake'] + %w[LICENSE README.md Rakefile VERSION]
  s.test_files = Dir.glob('spec/**/*')
end

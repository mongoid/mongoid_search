# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

case version = ENV['MONGOID_VERSION'] || '9'
when 'HEAD'
  gem 'mongoid', github: 'mongodb/mongoid'
when /^9/
  gem 'mongoid', '~> 9.0'
when /^8/
  gem 'mongoid', '~> 8'
when /^7/
  gem 'mongoid', '~> 7'
when /^6/
  gem 'mongoid', '~> 6'
else
  gem 'mongoid', version
end

group :development do
  gem 'database_cleaner-mongoid', '>= 2.0.0'
  gem 'mongoid-compatibility'
  gem 'ostruct'
  gem 'railties', version =~ /^6/ ? '~> 5.2.0' : '~> 7.0.0'
  gem 'rake', '>= 12.3.3'
  gem 'rspec', '~> 3.1'
  gem 'simplecov', '~> 0.22' if ENV['COVERAGE'] == 'true'
end

group :test do
  gem 'danger', require: false
  gem 'danger-changelog', require: false
  gem 'danger-pr-comment', require: false
end

group :development, :test do
  if RUBY_ENGINE == 'ruby' && Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.3')
    gem 'commonmarker', '~> 2.10', require: false
    gem 'rubocop', '~> 1.92'
    gem 'rubocop-md', '~> 3.0', require: false
    gem 'rubocop-prose', '~> 0.2', require: false
    gem 'rubocop-rake', '~> 0.7', require: false
    gem 'rubocop-spellcheck', '~> 0.2', require: false
    gem 'rubocop-yaml', '~> 0.1.0', require: false
    gem 'ruby-gem-release', '0.9.0', require: false
  end
end

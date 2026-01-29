# frozen_string_literal: true

source 'http://rubygems.org'

gemspec

case version = ENV['MONGOID_VERSION'] || '8'
when 'HEAD'
  gem 'mongoid', github: 'mongodb/mongoid'
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
  gem 'rake', '>= 12.3.3'
  gem 'rubocop', '1.56.0'
  gem 'simplecov'
end

group :test do
  gem 'danger', require: false
  gem 'danger-changelog', require: false
  gem 'danger-pr-comment', require: false
end

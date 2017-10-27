source 'http://rubygems.org'

gemspec

gem 'simplecov', '>= 0.4.0', :require => false, :group => :test

mongoid_version =
  case ENV['MONGOID_VERSION']
  # TODO: uncomment this option when all specs pass for 6.0
  # when /^6/
    # '~> 6.0'
  when /^5/
    '~> 5.0'
  when /^4/
    '~> 4.0'
  when /^3/
    '~> 3.1'
  else
    # TODO: change default value to '~> 6.0' when all specs pass for 6.0
    '~> 5.0'
  end

gem 'mongoid', mongoid_version

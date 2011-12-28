require 'mongoid_search'
require 'rails'

module MongoidSearch
  class Railtie < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__), '../../tasks/*.rake')].each { |f| load f }
    end
  end
end
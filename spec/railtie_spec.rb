# frozen_string_literal: true

require 'spec_helper'
require 'rake'
require 'rails/railtie'
require 'rails/application'
require 'mongoid_search/railtie'

describe Mongoid::Search::Railtie do
  before(:all) do
    @rake_application = Rake.application
    Rake.application = Rake::Application.new
    described_class.instance.send(:run_tasks_blocks, described_class.instance)
    Rake::Task.define_task(:environment)
  end

  after(:all) do
    Rake.application = @rake_application
  end

  around do |example|
    silent = Mongoid::Search::Log.silent
    example.run
  ensure
    Rake::Task['mongoid_search:index'].reenable
    Mongoid::Search::Log.silent = silent
  end

  before do
    application = instance_double(Rails::Application, eager_load!: nil)
    allow(Rails).to receive(:application).and_return(application)
  end

  it 'registers the public indexing rake task with Rails' do
    expect(Rake::Task.task_defined?('mongoid_search:index')).to be true
    expect(Rake::Task['mongoid_search:index'].prerequisites).to include('environment')
  end

  it 'eager loads the application and reports when no models are registered' do
    allow(Mongoid::Search).to receive(:classes).and_return([])
    expect(Rails.application).to receive(:eager_load!)

    expect { Rake::Task['mongoid_search:index'].invoke }
      .to output("No model to index keywords.\n").to_stdout
  end

  it 'indexes the registered models' do
    product = Product.create!(name: 'Coverage')
    Product.collection.find(_id: product.id).update_one('$unset' => { _keywords: '' })
    allow(Mongoid::Search).to receive(:classes).and_return([Product])
    expect(Rails.application).to receive(:eager_load!)

    expect { Rake::Task['mongoid_search:index'].invoke }
      .to output(/Indexing documents for Product:.*Done/m).to_stdout
    expect(product.reload._keywords).to eq(['coverage'])
  end
end

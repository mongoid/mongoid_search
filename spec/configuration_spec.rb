# frozen_string_literal: true

require 'spec_helper'

describe Mongoid::Search do
  it 'yields the public configuration module' do
    expect { |block| described_class.setup(&block) }.to yield_with_args(described_class)
  end
end

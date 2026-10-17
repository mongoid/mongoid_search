# frozen_string_literal: true

require 'spec_helper'

describe Mongoid::Search::Log do
  around do |example|
    original = described_class.silent
    described_class.silent = false
    example.run
  ensure
    described_class.silent = original
  end

  it 'prints failures in red' do
    expect { described_class.red('F') }.to output("\033[31mF\033[0m").to_stdout
  end

  it 'prints successes in green' do
    expect { described_class.green('.') }.to output("\033[32m.\033[0m").to_stdout
  end

  it 'does not print when silent' do
    described_class.silent = true
    expect { described_class.red('F') }.not_to output.to_stdout
  end
end

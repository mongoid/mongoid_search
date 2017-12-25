
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Mongoid::Search::Util do
  before(:all) do
    @default_proc = Mongoid::Search.stem_proc
  end

  after(:all) do
    Mongoid::Search.stem_proc = @default_proc
  end

  before do
    Mongoid::Search.stem_keywords = false
    Mongoid::Search.ignore_list = ''
    Mongoid::Search.stem_proc = @default_proc
  end

  it 'should return an empty array if no text is passed' do
    expect(Mongoid::Search::Util.normalize_keywords('')).to eq []
  end

  it 'should return an array of keywords' do
    expect(Mongoid::Search::Util.normalize_keywords('keyword').class).to eq Array
  end

  it 'should return an array of strings' do
    expect(Mongoid::Search::Util.normalize_keywords('keyword').first.class).to eq String
  end

  it 'should remove accents from the text passed' do
    expect(Mongoid::Search::Util.normalize_keywords('café')).to eq ['cafe']
  end

  it 'should downcase the text passed' do
    expect(Mongoid::Search::Util.normalize_keywords('CaFé')).to eq ['cafe']
  end

  it 'should downcase utf-8 chars of the text passed' do
    expect(Mongoid::Search::Util.normalize_keywords('Кафе')).to eq ['кафе']
  end

  it 'should split whitespaces, hifens, dots, underlines, etc..' do
    expect(Mongoid::Search::Util.normalize_keywords("CaFé-express.com delicious;come visit, and 'win' an \"iPad\"")).to eq %w[cafe express com delicious come visit and win an ipad]
  end

  it 'should stem keywords' do
    Mongoid::Search.stem_keywords = true
    expect(Mongoid::Search::Util.normalize_keywords('A runner running and eating')).to eq %w[runner run and eat]
  end

  it 'should stem keywords using a custom proc' do
    Mongoid::Search.stem_keywords = true
    Mongoid::Search.stem_proc = ->(word) { word.upcase }

    expect(Mongoid::Search::Util.normalize_keywords('A runner running and eating')).to eq %w[RUNNER RUNNING AND EATING]
  end

  it 'should ignore keywords from ignore list' do
    Mongoid::Search.stem_keywords = true
    Mongoid::Search.ignore_list = YAML.safe_load(File.open(File.dirname(__FILE__) + '/config/ignorelist.yml'))['ignorelist']
    expect(Mongoid::Search::Util.normalize_keywords('An amazing awesome runner running and eating')).to eq %w[an runner run and eat]
  end

  it 'should ignore keywords with less than two words' do
    expect(Mongoid::Search::Util.normalize_keywords('A runner running')).not_to include 'a'
  end

  it 'should not ignore numbers' do
    expect(Mongoid::Search::Util.normalize_keywords('Ford T 1908')).to include '1908'
  end
end

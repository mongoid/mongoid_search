require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Mongoid::Search do
  before(:all) do
    @default_proc = Mongoid::Search.stem_proc
    @default_strip_symbols = Mongoid::Search.strip_symbols
    @default_strip_accents = Mongoid::Search.strip_accents
  end

  after(:all) do
    Mongoid::Search.stem_proc = @default_proc
  end

  before(:each) do
    Mongoid::Search.match         = :any
    Mongoid::Search.stem_keywords = false
    Mongoid::Search.ignore_list   = nil
    Mongoid::Search.stem_proc     = @default_proc
    @product = Product.create brand: 'Apple',
                              name: 'iPhone',
                              unit: 'mobile olé awesome',
                              tags: (@tags = %w[Amazing Awesome Olé].map { |tag| Tag.new(name: tag) }),
                              category: Category.new(name: 'Mobile', description: 'Reviews'),
                              subproducts: [Subproduct.new(brand: 'Apple', name: 'Craddle')],
                              info: { summary: 'Info-summary',
                                      description: 'Info-description' }
  end

  describe 'Serialized hash fields' do
    context 'when the hash is populated' do
      it 'should return the product' do
        expect(Product.full_text_search('Info-summary').first).to eq @product
        expect(Product.full_text_search('Info-description').first).to eq @product
      end
    end

    context 'when the hash is empty' do
      before(:each) do
        @product.info = nil
        @product.save
      end

      it 'should not return the product' do
        expect(Product.full_text_search('Info-description').size).to eq 0
        expect(Product.full_text_search('Info-summary').size).to eq 0
      end
    end
  end

  context 'utf-8 characters' do
    before do
      Mongoid::Search.stem_keywords = false
      Mongoid::Search.ignore_list   = nil
      @product = Product.create brand: 'Эльбрус',
                                name: 'Процессор',
                                unit: 'kílográm Olé',
                                tags: %w[Amazing Awesome Olé].map { |tag| Tag.new(name: tag) },
                                category: Category.new(name: 'процессоры'),
                                subproducts: []
    end

    it 'should leave utf8 characters' do
      expect(@product._keywords).to eq %w[amazing awesome ole процессор процессоры эльбрус]
      expect(@product._unit_keywords).to eq %w[kilogram ole]
    end

    it "should return results in search when case doesn't match" do
      expect(Product.full_text_search('ЭЛЬБРУС').size).to eq 1
      expect(Product.full_text_search('KILOGRAM', index: :_unit_keywords).size).to eq 1
    end
  end

  context 'when references are nil' do
    context 'when instance is being created' do
      it 'should not complain about method missing' do
        expect { Product.create! }.not_to raise_error
      end
    end

    it 'should validate keywords' do
      product = Product.create brand: 'Apple', name: 'iPhone', unit: 'box'
      expect(product._keywords).to eq(%w[apple iphone])
      expect(product._unit_keywords).to eq(%w[box])
    end
  end

  it 'should set the _keywords field for array fields also' do
    @product.attrs = ['lightweight', 'plastic', :red]
    @product.measures = ['box', 'bunch', :bag]
    @product.save!
    expect(@product._keywords).to include 'lightweight', 'plastic', 'red'
    expect(@product._unit_keywords).to include 'box', 'bunch', 'bag'
  end

  it 'should inherit _keywords field and build upon' do
    variant = Variant.create brand: 'Apple',
                             name: 'iPhone',
                             tags: %w[Amazing Awesome Olé].map { |tag| Tag.new(name: tag) },
                             category: Category.new(name: 'Mobile'),
                             subproducts: [Subproduct.new(brand: 'Apple', name: 'Craddle')],
                             color: :white,
                             size: :big
    expect(variant._keywords).to include 'white'
    expect(variant._unit_keywords).to include 'big'
    expect(Variant.full_text_search(name: 'Apple', color: :white)).to eq [variant]
    expect(Variant.full_text_search({ size: 'big' }, index: :_unit_keywords)).to eq [variant]
  end

  it 'should expand the ligature to ease searching' do
    # ref: http://en.wikipedia.org/wiki/Typographic_ligature, only for french right now. Rules for other languages are not know
    variant1 = Variant.create tags: ['œuvre'].map { |tag| Tag.new(name: tag) }
    variant2 = Variant.create tags: ['æquo'].map { |tag| Tag.new(name: tag) }
    variant3 = Variant.create measures: ['ꜵquo'].map { |measure| measure }

    expect(Variant.full_text_search('œuvre')).to eq [variant1]
    expect(Variant.full_text_search('oeuvre')).to eq [variant1]
    expect(Variant.full_text_search('æquo')).to eq [variant2]
    expect(Variant.full_text_search('aequo')).to eq [variant2]
    expect(Variant.full_text_search('aoquo', index: :_unit_keywords)).to eq [variant3]
    expect(Variant.full_text_search('ꜵquo', index: :_unit_keywords)).to eq [variant3]
  end

  it 'should set the keywords fields with stemmed words if stem is enabled' do
    Mongoid::Search.stem_keywords = true
    @product.save!
    expect(@product._keywords.sort).to eq %w[amaz appl awesom craddl iphon mobil review ol info descript summari].sort
    expect(@product._unit_keywords.sort).to eq %w[mobil awesom ol].sort
  end

  it 'should set the keywords fields with custom stemmed words if stem is enabled with a custom lambda' do
    Mongoid::Search.stem_keywords = true
    Mongoid::Search.stem_proc     = proc { |word| word.upcase }
    @product.save!
    expect(@product._keywords.sort).to eq %w[AMAZING APPLE AWESOME CRADDLE DESCRIPTION INFO IPHONE MOBILE OLE REVIEWS SUMMARY]
    expect(@product._unit_keywords.sort).to eq %w[AWESOME MOBILE OLE]
  end

  it 'should ignore keywords in an ignore list' do
    Mongoid::Search.ignore_list = YAML.safe_load(File.open(File.dirname(__FILE__) + '/config/ignorelist.yml'))['ignorelist']
    @product.save!
    expect(@product._keywords.sort).to eq %w[apple craddle iphone mobile reviews ole info description summary].sort
    expect(@product._unit_keywords.sort).to eq %w[mobile ole].sort
  end

  it 'should incorporate numbers as keywords' do
    @product = Product.create brand: 'Ford',
                              name: 'T 1908',
                              tags: %w[Amazing First Car].map { |tag| Tag.new(name: tag) },
                              category: Category.new(name: 'Vehicle')

    @product.save!
    expect(@product._keywords).to eq %w[1908 amazing car first ford vehicle]
  end

  it 'should return results in search' do
    expect(Product.full_text_search('apple').size).to eq 1
  end

  it 'should return results in search for dynamic attribute' do
    @product[:outlet] = 'online shop'
    @product.save!
    expect(Product.full_text_search('online').size).to eq 1
  end

  it 'should return results in search even searching a accented word' do
    expect(Product.full_text_search('Ole').size).to eq 1
    expect(Product.full_text_search('Olé').size).to eq 1
  end

  it "should return results in search even if the case doesn't match" do
    expect(Product.full_text_search('oLe').size).to eq 1
  end

  it 'should return results in search with a partial word by default' do
    expect(Product.full_text_search('iph').size).to eq 1
  end

  it 'should return results for any matching word with default search' do
    expect(Product.full_text_search('apple motorola').size).to eq 1
  end

  it 'should not return results when all words do not match, if using :match => :all' do
    Mongoid::Search.match = :all
    expect(Product.full_text_search('apple motorola').size).to eq 0
  end

  it 'should return results for any matching word, using :match => :all, passing :match => :any to .full_text_search' do
    Mongoid::Search.match = :all
    expect(Product.full_text_search('apple motorola', match: :any).size).to eq 1
  end

  it 'should not return results when all words do not match, passing :match => :all to .full_text_search' do
    expect(Product.full_text_search('apple motorola', match: :all).size).to eq 0
  end

  it 'should return no results when a blank search is made' do
    Mongoid::Search.allow_empty_search = false
    expect(Product.full_text_search('').size).to eq 0
  end

  it 'should return results when a blank search is made when :allow_empty_search is true' do
    Mongoid::Search.allow_empty_search = true
    expect(Product.full_text_search('').size).to eq 1
  end

  it 'should search for embedded documents' do
    expect(Product.full_text_search('craddle').size).to eq 1
  end

  it 'should search for reference documents' do
    expect(Product.full_text_search('reviews').size).to eq 1
  end

  it 'should work in a chainable fashion' do
    expect(@product.category.products.where(brand: 'Apple').full_text_search('apple').size).to eq 1
    expect(@product.category.products.full_text_search('craddle').where(brand: 'Apple').size).to eq 1
  end

  it 'should return the classes that include the search module' do
    expect(Mongoid::Search.classes.sort_by(&:name)).to eq [Product, Tag]
  end

  it 'should have a method to index keywords' do
    expect(@product.index_keywords!).to include(true)
  end

  it 'should have a class method to index all documents keywords' do
    expect(Product.index_keywords!).not_to include(false)
  end

  context 'when regex search is false' do
    before do
      Mongoid::Search.regex_search = false
    end

    it 'should not return results in search with a partial word if not using regex search' do
      expect(Product.full_text_search('iph').size).to eq 0
    end

    it 'should return results in search with a full word if not using regex search' do
      expect(Product.full_text_search('iphone').size).to eq 1
    end
  end

  context 'when regex search is true' do
    before do
      Mongoid::Search.regex_search = true
    end

    after do
      Mongoid::Search.regex_search = false
    end

    it 'should not return results in search with a partial word if using regex search' do
      expect(Product.full_text_search('iph').size).to eq 1
    end

    it 'should return results in search with a full word if using regex search' do
      expect(Product.full_text_search('iphone').size).to eq 1
    end

    context 'when query include special characters that should not be stripped' do
      before do
        Mongoid::Search.strip_symbols = /[\n]/
        Mongoid::Search.strip_accents = /[^\s\p{Graph}]/
      end

      after do
        Mongoid::Search.strip_symbols = @default_strip_symbols
        Mongoid::Search.strip_accents = @default_strip_accents
      end

      it 'should escape regex special characters' do
        expect(Product.full_text_search('iphone (steve').size).to eq 1
      end
    end

    context 'Match partial words on the beginning' do
      before do
        Mongoid::Search.regex = proc { |query| /^#{query}/ }
      end

      it 'should return results in search which starts with query string' do
        expect(Product.full_text_search('iphone').size).to eq 1
      end

      it 'should not return results in search which does not start with query string' do
        expect(Product.full_text_search('phone').size).to eq 0
      end
    end

    context 'Match partial words on the end' do
      before do
        Mongoid::Search.regex = proc { |query| /#{query}$/ }
      end

      it 'should return results in search which ends with query string' do
        expect(Product.full_text_search('phone').size).to eq 1
      end

      it 'should not return results in search which does not end with query string' do
        expect(Product.full_text_search('phon').size).to eq 0
      end
    end
  end

  context 'relevant search' do
    before do
      Mongoid::Search.relevant_search = true
      @imac = Product.create name: 'apple imac'
    end

    it 'should return results ordered by relevance and with correct ids' do
      expect(Product.full_text_search('apple imac').map(&:_id)).to eq [@imac._id, @product._id]
    end

    it 'results should be recognized as persisted objects' do
      expect(Product.full_text_search('apple imac').map(&:persisted?)).not_to include false
    end

    it 'should include relevance information' do
      expect(Product.full_text_search('apple imac').map(&:relevance)).to eq [2, 1]
    end
  end

  context 'when using methods for keywords' do
    it 'should set the _keywords from methods' do
      expect(@tags.first._keywords).to include 'amazing'
    end
  end

  context 'when using deeply nested fields for keywords' do
    context 'when explicitly calling set_keywords' do
      it 'should set the _keywords from parent' do
        @tags.first.send(:set_keywords)
        expect(@tags.first._keywords).to eq %w[amazing description info iphone mobile reviews summary]
      end
    end
  end

  context 'when using localized fields' do
    it 'should set the keywords from all localizations' do
      @product = Product.create brand: 'Ford',
                                name: 'T 1908',
                                tags: %w[Amazing First Car].map { |tag| Tag.new(name: tag) },
                                category: Category.new(name_translations: { en: 'Vehicle', de: 'Fahrzeug' })
      expect(@product._keywords).to include('fahrzeug')
    end
  end

  context 'minimum word size' do
    before(:each) do
      Mongoid::Search.minimum_word_size = 3
    end

    after(:each) do
      Mongoid::Search.minimum_word_size = 2
    end

    it 'should ignore keywords with length less than minimum word size' do
      @product = Product.create name: 'a'
      expect(@product._keywords.size).to eq 0

      @product = Product.create name: 'ap'
      expect(@product._keywords.size).to eq 0

      @product = Product.create name: 'app'
      expect(@product._keywords.size).to eq 1
    end
  end
end

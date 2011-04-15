# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Mongoid::Search do

  before(:each) do
    Product.stem_keywords = false
    Product.ignore_list   = nil
    @product = Product.create :brand => "Apple",
                              :name => "iPhone",
                              :tags => ["Amazing", "Awesome", "Olé"].map { |tag| Tag.new(:name => tag) },
                              :category => Category.new(:name => "Mobile"),
                              :subproducts => [Subproduct.new(:brand => "Apple", :name => "Craddle")]
  end

  context "utf-8 characters" do
    before(:each) {
      Product.stem_keywords = false
      Product.ignore_list   = nil
      @product = Product.create :brand => "Эльбрус",
                                :name => "Процессор",
                                :tags => ["Amazing", "Awesome", "Olé"].map { |tag| Tag.new(:name => tag) },
                                :category => Category.new(:name => "процессоры"),
                                :subproducts => []
    }

    it "should leave utf8 characters" do
      @product._keywords.should == ["amazing", "awesome", "ole", "Процессор", "Эльбрус", "процессоры"]
    end
  end

  it "should set the _keywords field for array fields also" do
    @product.attrs = ['lightweight', 'plastic', :red]
    @product.save!
    @product._keywords.should include 'lightweight', 'plastic', 'red'
  end
  
  it "should inherit _keywords field and build upon" do
    variant = Variant.create :brand => "Apple",
                              :name => "iPhone",
                              :tags => ["Amazing", "Awesome", "Olé"].map { |tag| Tag.new(:name => tag) },
                              :category => Category.new(:name => "Mobile"),
                              :subproducts => [Subproduct.new(:brand => "Apple", :name => "Craddle")],
                              :color => :white
    variant._keywords.should include 'white'
    Variant.search(:name => 'Apple', :color => :white).should eq [variant]
  end

  it "should set the _keywords field with stemmed words if stem is enabled" do
    Product.stem_keywords = true
    @product.save!
    @product._keywords.should == ["amaz", "appl", "awesom", "craddl", "iphon", "mobil", "ol"]
  end

  it "should ignore keywords in an ignore list" do
    Product.ignore_list = YAML.load(File.open(File.dirname(__FILE__) + '/config/ignorelist.yml'))["ignorelist"]
    @product.save!
    @product._keywords.should == ["apple", "craddle", "iphone", "mobile", "ole"]
  end

   it "should incorporate numbers as keywords" do
        @product = Product.create :brand => "Ford",
                              :name => "T 1908",
                              :tags => ["Amazing", "First", "Car"].map { |tag| Tag.new(:name => tag) },
                              :category => Category.new(:name => "Vehicle")

      @product.save!
      @product._keywords.should == ["1908","amazing", "car", "first", "ford",  "vehicle"]
   end


  it "should return results in search" do
    Product.search("apple").size.should == 1
  end

  it "should return results in search for dynamic attribute" do
    @product[:outlet] = "online shop"
    @product.save!
    Product.search("online").size.should == 1
  end

  it "should return results in search even searching a accented word" do
    Product.search("Ole").size.should == 1
    Product.search("Olé").size.should == 1
  end

  it "should return results in search even if the case doesn't match" do
    Product.search("oLe").size.should == 1
  end

  it "should return results in search with a partial word" do
    Product.search("iph").size.should == 1
  end

  it "should return results for any matching word with default search" do
    Product.search("apple motorola").size.should == 1
  end

  it "should not return results when all words do not match, if using :match => :all" do
    Product.match = :all
    Product.search("apple motorola").size.should == 0
  end

  it "should return results for any matching word, using :match => :all, passing :match => :any to .search" do
    Product.match = :all
    Product.search("apple motorola", :match => :any).size.should == 1
  end

  it "should not return results when all words do not match, passing :match => :all to .search" do
    Product.search("apple motorola", :match => :all).size.should == 0
  end

  it "should return no results when a blank search is made" do
    Product.search("").size.should == 0
  end

  it "should return results when a blank search is made when :allow_empty_search is true" do
    Product.allow_empty_search = true
    Product.search("").size.should == 1
  end

  it "should search for embedded documents" do
    Product.search("craddle").size.should == 1
  end
  
  it 'should work in a chainable fashion' do
    @product.category.products.where(:brand => 'Apple').csearch('apple').size.should == 1
    @product.category.products.csearch('craddle').where(:brand => 'Apple').size.should == 1
  end
  
end

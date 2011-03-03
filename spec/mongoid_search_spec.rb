# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Mongoid::Search do
  
  before(:each) do
    @product = Product.create :brand => "Apple",
                              :name => "iPhone",
                              :tags => ["Amazing", "Awesome", "Olé"].map { |tag| Tag.new(:name => tag) },
                              :category => Category.new(:name => "Mobile"),
                              :subproducts => [Subproduct.new(:brand => "Apple", :name => "Craddle")]
  end
  
  context "utf-8 characters" do
    before(:each) {
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
  
  it "should set the _keywords field" do
    @product._keywords.should == ["amazing", "apple", "apple", "awesome", "craddle", "iphone", "mobile", "ole"]
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
end

# encoding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Mongoid::Search do
  
  before(:each) do
    @product = Product.create :brand => "Apple", :name => "iPhone", :tags => ["Amazing", "Awesome", "Olé"].map { |tag| Tag.new(:name => tag) }
  end
  
  it "should set the _keywords field" do
    @product._keywords.should == ["apple", "iphone", "amazing", "awesome", "ole"]
  end
    
  it "should return results in search" do
    Product.search("apple").size.should == 1
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
end

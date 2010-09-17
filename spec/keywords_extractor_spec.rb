# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe KeywordsExtractor do
  it "should return if no text is passed" do
    KeywordsExtractor.extract("").should == nil
  end
    
  it "should return an array of keywords" do
    KeywordsExtractor.extract("keyword").class.should == Array
  end  
  
  it "should return an array of strings" do
    KeywordsExtractor.extract("keyword").first.class.should == String
  end
  
  it "should remove accents from the text passed" do
    KeywordsExtractor.extract("café").should == ["cafe"]
  end
    
  it "should downcase the text passed" do
    KeywordsExtractor.extract("CaFé").should == ["cafe"]
  end
    
  it "should split whitespaces, hifens, dots and underlines" do
    KeywordsExtractor.extract("CaFé-express.com delicious").should == ["cafe", "express", "com", "delicious"]
  end
end

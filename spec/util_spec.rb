# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe MongoidSearch::Util do
  Util = MongoidSearch::Util

  it "should return an empty array if no text is passed" do
    Util.normalize_keywords("", false, "").should == []
  end

  it "should return an array of keywords" do
    Util.normalize_keywords("keyword", false, "").class.should == Array
  end

  it "should return an array of strings" do
    Util.normalize_keywords("keyword", false, "").first.class.should == String
  end

  it "should remove accents from the text passed" do
    Util.normalize_keywords("café", false, "").should == ["cafe"]
  end

  it "should downcase the text passed" do
    Util.normalize_keywords("CaFé", false, "").should == ["cafe"]
  end

  it "should downcase utf-8 chars of the text passed" do
    Util.normalize_keywords("Кафе", false, "").should == ["кафе"]
  end

  it "should split whitespaces, hifens, dots, underlines, etc.." do
    Util.normalize_keywords("CaFé-express.com delicious;come visit, and 'win' an \"iPad\"", false, "").should == ["cafe", "express", "com", "delicious", "come", "visit", "and", "win", "an", "ipad"]
  end

  it "should stem keywords" do
    Util.normalize_keywords("A runner running and eating", MongoidSearch::FastStemmer.new, "").should == ["runner", "run", "and", "eat"]
  end

  it "should ignore keywords from ignore list" do
    Util.normalize_keywords("An amazing awesome runner running and eating", MongoidSearch::FastStemmer.new, YAML.load(File.open(File.dirname(__FILE__) + '/config/ignorelist.yml'))["ignorelist"]).should == ["an", "runner", "run", "and", "eat"]
  end

  it "should ignore keywords with less than two words" do
    Util.normalize_keywords("A runner running", false, "").should_not include "a"
  end

   it "should not ignore numbers" do
      Util.normalize_keywords("Ford T 1908", false, "").should include "1908"
   end
end

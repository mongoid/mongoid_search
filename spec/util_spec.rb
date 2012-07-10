# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Util do
  before do
    Mongoid::Search.stem_keywords = false
    Mongoid::Search.ignore_list = ""
  end

  it "should return an empty array if no text is passed" do
    Util.normalize_keywords("").should == []
  end

  it "should return an array of keywords" do
    Util.normalize_keywords("keyword").class.should == Array
  end

  it "should return an array of strings" do
    Util.normalize_keywords("keyword").first.class.should == String
  end

  it "should remove accents from the text passed" do
    Util.normalize_keywords("café").should == ["cafe"]
  end

  it "should downcase the text passed" do
    Util.normalize_keywords("CaFé").should == ["cafe"]
  end

  it "should downcase utf-8 chars of the text passed" do
    Util.normalize_keywords("Кафе").should == ["кафе"]
  end

  it "should split whitespaces, hifens, dots, underlines, etc.." do
    Util.normalize_keywords("CaFé-express.com delicious;come visit, and 'win' an \"iPad\"").should == ["cafe", "express", "com", "delicious", "come", "visit", "and", "win", "an", "ipad"]
  end

  it "should stem keywords" do
    Mongoid::Search.stem_keywords = true
    Util.normalize_keywords("A runner running and eating").should == ["runner", "run", "and", "eat"]
  end

  it "should ignore keywords from ignore list" do
    Mongoid::Search.stem_keywords = true
    Mongoid::Search.ignore_list = YAML.load(File.open(File.dirname(__FILE__) + '/config/ignorelist.yml'))["ignorelist"]
    Util.normalize_keywords("An amazing awesome runner running and eating").should == ["an", "runner", "run", "and", "eat"]
  end

  it "should ignore keywords with less than two words" do
    Util.normalize_keywords("A runner running").should_not include "a"
  end

  it "should not ignore numbers" do
    Util.normalize_keywords("Ford T 1908").should include "1908"
  end
end

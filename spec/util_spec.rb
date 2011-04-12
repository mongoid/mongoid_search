# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Util do
  it "should return an empty array if no text is passed" do
    Util.keywords("", false, "").should == []
  end

  it "should return an array of keywords" do
    Util.keywords("keyword", false, "").class.should == Array
  end

  it "should return an array of strings" do
    Util.keywords("keyword", false, "").first.class.should == String
  end

  it "should remove accents from the text passed" do
    Util.keywords("café", false, "").should == ["cafe"]
  end

  it "should downcase the text passed" do
    Util.keywords("CaFé", false, "").should == ["cafe"]
  end

  it "should split whitespaces, hifens, dots, underlines, etc.." do
    Util.keywords("CaFé-express.com delicious;come visit, and 'win' an \"iPad\"", false, "").should == ["cafe", "express", "com", "delicious", "come", "visit", "and", "win", "an", "ipad"]
  end

  it "should stem keywords" do
    Util.keywords("A runner running and eating", true, "").should == ["runner", "run", "and", "eat"]
  end

  it "should ignore keywords from ignore list" do
    Util.keywords("An amazing awesome runner running and eating", true, YAML.load(File.open(File.dirname(__FILE__) + '/config/ignorelist.yml'))["ignorelist"]).should == ["an", "runner", "run", "and", "eat"]
  end

  it "should ignore keywords with less than two words" do
    Util.keywords("A runner running", false, "").should_not include "a"
  end

   it "should not ignore numbers" do
      Util.keywords("Ford T 1908", false, "").should include "1908"
   end
end

# encoding: utf-8

require 'mongoid_search/railtie' if defined?(Rails)
require 'mongoid_search/mongoid_search'

module Mongoid::Search
  ## Default matching type. Match :any or :all searched keywords
  mattr_accessor :match
  @@match = :any

  ## If true, an empty search will return all objects
  mattr_accessor :allow_empty_search
  @@allow_empty_search = false

  ## If true, will search with relevance information
  mattr_accessor :relevant_search
  @@relevant_search = false

  ## Stem keywords
  mattr_accessor :stem_keywords
  @@stem_keywords = false

  ## Words to ignore
  mattr_accessor :ignore_list
  @@ignore_list = []

  ## An array of words
  # @@ignore_list = %w{ a an to from as }

  ## Or from a file
  # @@ignore_list = YAML.load(File.open(File.dirname(__FILE__) + '/config/ignorelist.yml'))["ignorelist"]

  ## Search using regex (slower)
  mattr_accessor :regex_search
  @@regex_search = true

  ## Regex to search
  mattr_accessor :regex

  ## Match partial words on both sides (slower)
  @@regex = Proc.new { |query| /#{query}/ }

  ## Match partial words on the beginning or in the end (slightly faster)
  # @@regex = Proc.new { |query| /ˆ#{query}/ }
  # @@regex = Proc.new { |query| /#{query}$/ }

  # Ligatures to be replaced
  # http://en.wikipedia.org/wiki/Typographic_ligature
  mattr_accessor :ligatures
  @@ligatures = { "œ"=>"oe", "æ"=>"ae" }

  # Minimum word size. Words smaller than it won't be indexed
  mattr_accessor :minimum_word_size
  @@minimum_word_size = 2

  def self.setup
    yield self
  end
end

require 'mongoid_search/util'
require 'mongoid_search/log'
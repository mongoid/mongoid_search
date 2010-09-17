Mongoid Searh
============

Mongoid Search is a simple full text search implementation for Mongoid ORM.

Installation
--------

In your Gemfile:

    gem 'mongoid_search'
  
Then:
  
    bundle install

Examples
--------

    class Product
      include Mongoid::Document
      include Mongoid::Search
      field :brand
      field :name

      references_many :tags
      
      search_in :brand, :name, :tags => :name
    end

    class Tag
      include Mongoid::Document
      field :name

      referenced_in :product
    end

Now when you save a product, you get a _keywords field automatically:
    
    p = Product.new :brand => "Apple", :name => "iPhone"
    p.tags << Tag.new(:name => "Amazing")
    p.tags << Tag.new(:name => "Awesome")
    p.tags << Tag.new(:name => "Superb")
    p.save
    => true
    p._keywords
    
Now you can run search, which will look in the _keywords field and return all matching results:

    Product.search("apple iphone").size
    => 1
    
Note that the search is case insensitive, and accept partial searching too:

    Product.search("ipho").size
    => 1
    
Options
-------

:match:
  :any - match any occurrence
  :all - match all ocurrences 
  Default is :any.

    search_in :brand, :name, { :tags => :name }, { :match => :all }
    
    Product.search("apple motorola").size
    => 1

    search_in :brand, :name, { :tags => :name }, { :match => :all }
    
    Product.search("apple motorola").size
    => 0

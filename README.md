Mongoid Search
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
      refereced_in    :category
      
      search_in :brand, :name, :tags => :name, :category => :name
    end

    class Tag
      include Mongoid::Document
      field :name

      referenced_in :product
    end
    
    class Category
      include Mongoid::Document
      field :name

      references_many :products
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

match:  
  _:any_ - match any occurrence  
  _:all_ - match all ocurrences  
  Default is _:any_.

    search_in :brand, :name, { :tags => :name }, { :match => :any }
    
    Product.search("apple motorola").size
    => 1

    search_in :brand, :name, { :tags => :name }, { :match => :all }
    
    Product.search("apple motorola").size
    => 0
    
allow_empty_search:  
  _true_ - match any occurrence  
  _false_ - match all ocurrences  
  Default is _false_.

    search_in :brand, :name, { :tags => :name }, { :allow_empty_search => true }
    
    Product.search("").size
    => 1
    
TODO
----

* Word stemming enabled via a configuration (because it's useful only in english)
* Strip html with sanitize (https://github.com/rgrove/sanitize)
* Relevance ranking with a configuration file or param instead of a new method

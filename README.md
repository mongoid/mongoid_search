# Mongoid Search

Mongoid Search is a simple full text search implementation for Mongoid ORM. It performs well for small data sets. If your searchable model is big (i.e. 1.000.000+ records), solr or sphinx may suit you better.

##Installation

In your Gemfile:

```ruby
    gem 'mongoid_search'
```

If your project is still using mongoid 2.x.x, stick to mongoid_search 0.2.x:

```ruby
    gem 'mongoid_search', '~> 0.2.8'
```

Then:

    bundle install

## Examples

```ruby
class Product
  include Mongoid::Document
  include Mongoid::Search
  field :brand
  field :name
  field :info, :type => Hash

  has_many   :tags
  belongs_to :category

  search_in :brand, :name, :tags => :name, :category => :name, :info => [:summary, :description]
end

class Tag
  include Mongoid::Document
  field :name

  belongs_to :product
end

class Category
  include Mongoid::Document
  field :name

  has_many :products
end
```

Now when you save a product, you get a `_keywords` field automatically:

```ruby
p = Product.new :brand => "Apple", :name => "iPhone", :info => {:summary => "Info-summary", :description => "Info-description"}
p.tags << Tag.new(:name => "Amazing")
p.tags << Tag.new(:name => "Awesome")
p.tags << Tag.new(:name => "Superb")
p.save
=> true
p._keywords
=> ["amazing", "apple", "awesome", "iphone", "superb", "Info-summary", "Info-description"]
```

Now you can run search, which will look in the `_keywords` field and return all matching results:

```ruby
Product.full_text_search("apple iphone").size
# => 1
```

Note that the search is case insensitive, and accept partial searching too:

```ruby
Product.full_text_search("ipho").size
# => 1
```

Assuming you have a category with multiple products you can use the following
code to search for 'iphone' in products cheaper than $499

```ruby
@category.products.where(:price.lt => 499).full_text_search('iphone').asc(:price)
```

To index or reindex all existing records, run this rake task

    $ rake mongoid_search:index

## Options

### match

* `:any` - match any occurrence
* `:all` - match all ocurrences

Default is `:any`.

```ruby
Product.full_text_search("apple motorola", match: :any).size
# => 1

Product.full_text_search("apple motorola", match: :all).size
# => 0
```

### allow\_empty\_search

* `true` - will return Model.all
* `false` - will return []

Default is `false`.

```ruby
Product.full_text_search("", allow_empty_search: true).size
# => 1
```

### relevant_search

* `true` - Adds relevance information to the results
* `false` - No relevance information

Default is `false`.

```ruby
Product.full_text_search('amazing apple', relevant_search: true)
# => [#<Product _id: 5016e7d16af54efe1c000001, _type: nil, brand: "Apple", name: "iPhone", attrs: nil, info: nil, category_id: nil, _keywords: ["amazing", "apple", "awesome", "iphone", "superb"], relevance: 2.0>]
```

Please note that relevant_search will return an Array and not a Criteria object. The search method should always be called in the end of the method chain.

## Initializer

Alternatively, you can create an initializer to setup those options:

```ruby
Mongoid::Search.setup do |config|
  ## Default matching type. Match :any or :all searched keywords
  config.match = :any

  ## If true, an empty search will return all objects
  config.allow_empty_search = false

  ## If true, will search with relevance information
  config.relevant_search = false

  ## Stem keywords
  config.stem_keywords = false

  ## Add a custom proc returning strings to replace the default stemmer
  # For example using ruby-stemmer:
  # config.stem_proc = Proc.new { |word| Lingua.stemmer(word, :language => 'nl') }

  ## Words to ignore
  config.ignore_list = []

  ## An array of words
  # config.ignore_list = %w{ a an to from as }

  ## Or from a file
  # config.ignore_list = YAML.load(File.open(File.dirname(__FILE__) + '/config/ignorelist.yml'))["ignorelist"]

  ## Search using regex (slower)
  config.regex_search = true

  ## Regex to search

  ## Match partial words on both sides (slower)
  config.regex = Proc.new { |query| /#{query}/ }

  ## Match partial words on the beginning or in the end (slightly faster)
  # config.regex = Proc.new { |query| /^#{query}/ }
  # config.regex = Proc.new { |query| /#{query}$/ }

  # Ligatures to be replaced
  # http://en.wikipedia.org/wiki/Typographic_ligature
  config.ligatures = { "œ"=>"oe", "æ"=>"ae" }

  # Strip symbols regex to be replaced. These symbols will be replaced by space
  config.strip_symbols = /[._:;'\"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]]/

  # Strip accents regex to be replaced. These sybols will be removed after strip_symbols replacing
  config.strip_accents = /[^\s\p{Alnum}]/

  # Minimum word size. Words smaller than it won't be indexed
  config.minimum_word_size = 2
end
```

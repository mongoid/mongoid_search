class Article
  include Mongoid::Document
  include Mongoid::Search
  field :title

  search_all
end

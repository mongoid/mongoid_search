class Product
  include Mongoid::Document
  include Mongoid::Search
  field :brand
  field :name

  references_many :tags

  search_in :brand, :name, :tags => :name
end

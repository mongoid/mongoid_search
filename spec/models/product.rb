class Product
  include Mongoid::Document
  include Mongoid::Search
  field :brand
  field :name

  references_many :tags
  referenced_in   :category
  embeds_many     :subproducts

  search_in :brand, :name, :outlet, :tags => :name, :category => :name, :subproducts => [:brand, :name]
end

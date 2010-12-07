class Category
  include Mongoid::Document
  field :name

  references_many :products
end
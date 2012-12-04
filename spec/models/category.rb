class Category
  include Mongoid::Document
  field :name
  field :description

  has_many :products
end

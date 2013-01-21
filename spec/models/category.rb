class Category
  include Mongoid::Document
  field :name, localize: true
  field :description

  has_many :products
end

class Category
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic if ::Mongoid::VERSION >= '4'

  field :name, localize: true
  field :description

  has_many :products
end

class Subproduct
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic if ::Mongoid::VERSION >= '4'

  field :brand
  field :name

  embedded_in :product, inverse_of: :subproducts
end

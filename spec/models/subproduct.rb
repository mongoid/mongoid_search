class Subproduct
  include Mongoid::Document

  field :brand
  field :name

  embedded_in :product, :inverse_of => :subproducts
end

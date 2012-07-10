class Subproduct
  include Mongoid::Document

  field :brand
  field :name

  belongs_to :product, :inverse_of => :subproducts
end

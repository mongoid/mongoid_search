autoload :Product, "models/product.rb"
class Variant < Product
  field :color
  search_in :color
end

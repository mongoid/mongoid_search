autoload :Product, 'models/product.rb'
class Variant < Product
  field :color
  field :size
  search_in :color
  search_in :size, index: :_unit_keywords
end

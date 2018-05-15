class Product
  include Mongoid::Document
  include Mongoid::Search
  include Mongoid::Attributes::Dynamic if ::Mongoid::VERSION >= '4'

  field :brand
  field :name
  field :unit
  field :measures, type: Array
  field :attrs, type: Array
  field :info, type: Hash

  has_many :tags
  if Mongoid::Compatibility::Version.mongoid6_or_newer?
    belongs_to  :category, required: false
  else
    belongs_to  :category
  end
  embeds_many :subproducts

  search_in :brand, :name, :outlet, :attrs, tags: :name, category: %i[name description],
                                            subproducts: %i[brand name], info: %i[summary description]
  search_in :unit, :measures, index: :_unit_keywords
end

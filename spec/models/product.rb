class Product
  include Mongoid::Document
  include Mongoid::Search
  include Mongoid::Attributes::Dynamic if ::Mongoid::VERSION >= '4'

  field :brand
  field :name
  field :attrs, :type => Array
  field :info, :type => Hash

  has_many    :tags
  belongs_to  :category
  embeds_many :subproducts

  search_in :brand, :name, :outlet, :attrs, :tags => :name, :category => [:name, :description],
            :subproducts => [:brand, :name], :info => [ :summary, :description ]
end

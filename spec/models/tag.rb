class Tag
  include Mongoid::Document
  include Mongoid::Search
  include Mongoid::Attributes::Dynamic if ::Mongoid::VERSION >= '4'

  field :name

  belongs_to :product

  def title
    name
  end

  search_in :title, product: [:name, { info: %i[summary description], category: %i[name description] }]
end

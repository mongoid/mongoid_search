class Tag
  include Mongoid::Document
  include Mongoid::Search
  include Mongoid::Attributes::Dynamic if ::Mongoid::VERSION >= '4'

  field :name

  belongs_to :product

  def title
      self.name
  end

  search_in :title, :product => [:name, { :info => [ :summary, :description ], :category => [:name, :description]}]
end

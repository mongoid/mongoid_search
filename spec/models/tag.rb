class Tag
  include Mongoid::Document
  include Mongoid::Search

  field :name

  belongs_to :product

  def title
      self.name
  end

  search_in :title, :product => [:name, { :info => [ :summary, :description ], :category => [:name, :description]}]
end

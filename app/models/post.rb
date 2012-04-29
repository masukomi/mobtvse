class Post
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes

  field :title,         :type => String
  field :text,          :type => String
  field :draft,         :type => Boolean,   default: true
  field :aside,         :type => Boolean,   default: true
  field :url,           :type => String
  field :updated_at,    :type => DateTime
  field :created_at,    :type => DateTime

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  acts_as_url :title, :url_attribute => :slug

  default_scope order('created_at desc')

  def to_param
    slug
  end

  def external?
  	!url.blank?
  end
end

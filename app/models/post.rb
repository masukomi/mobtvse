require 'date'
class Post
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Taggable
  include Mongoid::Timestamps
  include Stringex::ActsAsUrl

  field :title,           :type => String
  field :slug,            :type => String
  field :text,            :type => String
  field :content,         :type => String
  field :meta_description,:type => String
  field :draft,           :type => Boolean,   default: true
  field :aside,           :type => Boolean,   default: true
  field :comments_enabled,:type => Boolean,   default: true
  field :url,             :type => String
  field :updated_at,      :type => DateTime
  field :created_at,      :type => DateTime
  field :posted_at,       :type => DateTime

  scope :order, order_by(:created_at => :desc) #.limit(100)
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  #acts_as_url :title, :url_attribute => :slug
  before_validation :slug_from_title
    # You can't call before_save on a field that is part of 
    # the validations

  def slug_from_title()
    if (self.title and self.slug.blank?)
      self.slug= title.to_url
    end
  end
  # NOTE: 
  # when setting the post into non-draft mode
  # we also create the posted_at date.
  # This is because we don't currently support setting 
  # future posted_at dates
  # We also create the url since it is based on the posted on
  # WARNING: if you make a post public
  # then set it to a draft until the next day ( or later ) 
  # and then make it public again THE URL WILL CHANGE
  def draft=(new_draft_status)
    if ((draft and not new_draft_status) or (draft and not posted_at) )
      #NOTE We'll have to change this in the future
      # when we allow people to set the post date
      # manually
      self.posted_at = DateTime.now
      self.url = self.posted_at.strftime(CONFIG['post_url_style']).gsub(':slug', slug.to_url)
    elsif (self.posted_at and not new_draft_status)
      self.posted_at = nil
      self.url = nil
    end
    
    super(new_draft_status)
  end

  def external?
    !url.blank?
  end

  def permalinkable?
    return posted_at.nil? ? false : true
  end
end

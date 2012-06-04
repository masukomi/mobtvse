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
  field :kudos,           :type => Integer,   default: 0
  field :updated_at,      :type => DateTime
  field :created_at,      :type => DateTime
  field :posted_at,       :type => DateTime

  scope :order, order_by(:created_at => :desc) #.limit(100)
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  #acts_as_url :title, :url_attribute => :slug
  before_validation :slug_from_title, :update_posted_at
    # You can't call before_save on a field that is part of 
    # the validations

  def slug_from_title()
    if (self.title and self.slug.blank?)
      self.slug= title.to_url
    end
  end
  def update_posted_at()
    if (! self.draft and ! self.posted_at)
      self.posted_at = DateTime.now
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
  # TODO: AFTER Admin UI makeover
  #       - remove the elsif block
  #       - add a field in the UI to set the date (month, day, year)
  #       - once it's posted the posted_at will remain 
  #         regardless of draft status until someone manually 
  #         changes it. 
  def draft=(new_draft_status)
    if ((draft and not new_draft_status) or (draft and not posted_at) )
      #NOTE We'll have to change this in the future
      # when we allow people to set the post date
      # manually
      self.posted_at = DateTime.now
      slug_from_title() unless slug 
         # a slugless post can happen during testing (pre-save), and I just want 
         # to guarantee that it doesn't cause issues in production
      self.url = self.posted_at.strftime(CONFIG['post_url_style']).gsub(':slug', slug.to_url)
    elsif (not draft and not new_draft_status) #it's currently posted, but about to not be
      self.posted_at = nil
      self.url = nil
    end
    
    super(new_draft_status)
  end

  def external?
    !url.blank? and ! draft
  end

  def future?
    unless (self.posted_at.nil?)
      return self.posted_at > DateTime.now
    end
    return false
  end

  def next
    # gt seems to have the same problems as lt
    # see details in def previous
    mostly_next_entries = self.class.all(:conditions=>{
              :posted_at.gt => self.posted_at, #(self.posted_at ? self.posted_at : self.created_at), :draft=>(! published), 
              :draft => false,
              :_id.ne=>self._id
            }, 
            :sort=>[:posted_at, :asc]).entries
    mostly_next_entries.each do |entry|
      if entry.posted_at > self.posted_at
        return entry
      end
    end
    return nil
  end

  def previous
  # there's a bug in mongoid's date comparisons
  # :posted_at.lt=>self.posted_at will include self 
  # and sometimes items that are actually greater than. 
  # so we have to get the closest we can and iterate until we find the right one.
    mostly_previous_entries = self.class.all(:conditions=>{
            :posted_at.lt => self.posted_at, #(self.posted_at ? self.posted_at : self.created_at), 
            :draft=>false, 
            :_id.ne=>self._id
            }, 
            :sort=>[:posted_at, :desc]
          ).entries
    mostly_previous_entries.each do |entry| 
      #puts "testing #{entry.posted_at} < #{self.posted_at}"
      if entry.posted_at < self.posted_at #(self.posted_at ? self.posted_at : self.created_at)
        #puts "it was! returning"
        return entry
      end
    end
    return nil
  end

  def permalinkable?
    return posted_at.nil? ? false : true
  end
  def self.get_boolean_fields
    unless @boolean_fields
      @@boolean_fields = []
      Post.fields.each do |f|
        @@boolean_fields << f[0] if f[1].type == Boolean
      end
    end
    return @@boolean_fields
  end
end

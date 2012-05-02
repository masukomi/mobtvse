class Post
  include Mongoid::Document
  include Mongoid::MultiParameterAttributes
  include Mongoid::Taggable
  include Stringex::ActsAsUrl

  field :title,           :type => String
  field :slug,            :type => String
  field :text,            :type => String
  field :content,         :type => String
  field :meta_description,:type => String
  field :draft,           :type => Boolean,   default: true
  field :aside,           :type => Boolean,   default: true
  field :url,             :type => String
  field :updated_at,      :type => DateTime
  field :created_at,      :type => DateTime

  scope :order, order_by(:created_at => :desc) #.limit(100)
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true
  acts_as_url :title, :url_attribute => :slug

  def to_param
    slug
  end

  def external?
  	!url.blank?
  end


  def ensure_unique_url
    url_attribute = self.class.url_attribute
    separator = self.class.duplicate_count_separator
    base_url = self.send(url_attribute)
    base_url = self.send(self.class.attribute_to_urlify).to_s.to_url(:allow_slash => self.allow_slash) if base_url.blank? || !self.only_when_blank
    #conditions = ["#{url_attribute} LIKE ?", base_url+'%']

    criteria = {:url_attribute.to_sym => /#{base_url}.*/}
    unless new_record?
      #conditions.first << " and id != ?"
      #conditions << id
      criteria[:id.ne] = id
    end
    # not using this functionilaty here
    #if self.class.scope_for_url
    #  conditions.first << " and #{self.class.scope_for_url} = ?"
    #  conditions << send(self.class.scope_for_url)
    #end
    #url_owners = self.class.find(:all, :conditions => conditions)
    url_owners = Post.where(criteria)
    write_attribute url_attribute, base_url
    if url_owners.any?{|owner| owner.send(url_attribute) == base_url}
      n = 1
      while url_owners.any?{|owner| owner.send(url_attribute) == "#{base_url}#{separator}#{n}"}
        n = n.succ
      end
      write_attribute url_attribute, "#{base_url}#{separator}#{n}"
    end
  end
end

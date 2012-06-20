class Image
  include Mongoid::Document

  field :filename,           :type => String
  field :title,              :type => String
  field :url,                :type => String
  field :uploaded_on,        :type => Date, default: Date.today

  validates :url, :presence => true
    # filename is optional when creating images 
    # that are just links to things uploaded elsewhere

  #TODO destroy method should remove image from s3
  # and then call super

end

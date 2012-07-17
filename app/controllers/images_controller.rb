class ImagesController < ApplicationController

@@BUCKET = CONFIG['s3']['image_bucket_name']

before_filter :authenticate # no exceptions
before_filter :setup_s3
layout 'admin'

def index
	@file_count = BinaryFile.count
	logger.debug("#{@images_count} images found")
	@months = []
	first_image = Image.order_by(:uploaded_on=>:asc).first
	if (first_image)
		first_image_date = first_image.uploaded_on
		first_of_month=Date.today.at_beginning_of_month.at_beginning_of_day
		month = Month.new(first_of_month)
		if (month.start <= first_image_date)
			@months << month
		else
			while (month.start >= first_image_date)
				@months << month
				month = month.previous()
			end
			logger.debug("adding month: #{month}")
			@months << month 
		end
		# the month whose start isn't after the first image
	end
end

def new

end
def create
	#TODO support uploading images to the local filesystem
	#file_up = params[:upload]
	file_up = params[:image]
	filename = nil
	url = nil
	content_type = nil
	if s3_enabled? and file_up[:datafile]
		# if they don't upload anything there will be a file_up
		# with an empty title and nothing else
		content_type = file_up[:datafile].headers.gsub(/\r\n|\n/, ' ').sub(/.*?Content-Type: (\S+).*?/, '\1')
	elsif ! s3_enabled? and file_up[:url]
		extension =  file_up[:url].downcase.sub(/.*\.(\w+)$/, '\1')
			#downcasing so that we don't have to bother with case-insensitivity later
		content_type = nil
		if (extension.match(/swf$/))
			content_type = "application/x-shockwave-flash"
		elsif (extension.match(/(jpg|png|gif|jpeg|bmp|ico)$/))
			content_type = "image/#{extension}"
		elsif (extension.match(/^xml$/))
			content_type = 'text/xml'
		elsif (extension.match(/(txt|text|html|htm|xhtml)$/))
			content_type = extension.start_with?('txt', 'text') ? 'text/plain' : 'text/html'
		else
			content_type = 'application/octet-stream'
		end

	end
	if (! s3_enabled? and ! file_up[:url]) or (s3_enabled? and ! file_up[:datafile])
		# they didn't enter an url
		if s3_enabled?
			flash[:error] = "You must enter a file"
		else
			flash[:error] = "You must upload an url"
		end
		render :action => :new
		return
	end

	today = Date.today
	if s3_enabled?
		orig_filename = file_up[:datafile].original_filename
		filename = "#{today.year}_#{today.month}_#{today.day}_#{sanitize_filename(orig_filename)}"
		logger.debug("filename: #{filename}")
		AWS::S3::S3Object.store(filename, file_up['datafile'].read, @@BUCKET, :access => :public_read)
		url = AWS::S3::S3Object.url_for(filename, @@BUCKET, :authenticated => false)
		logger.debug("url for amazon file: #{url}")
	else
		url = file_up[:url]
	end
	
	@file = nil
	if content_type.match(/^image\//i)
		@file = Image.new(:title=>file_up[:title], :filename=>filename, :url=>url, :content_type=>content_type, :uploaded_on => today)
	else
		@file = BinaryFile.new(:title=>file_up[:title], :filename=>filename, :url=>url, :content_type=>content_type, :uploaded_on => today)
	end
	if @file.save
		redirect_to '/images/index'
	else
		flash[:error] = "Unable to save file!"
	end
end

def destroy
	@image = Image.find(params[:id])
	if (@image and @image.filename and @image.url.include?('s3.amazonaws.com'))
		#AWS::S3::S3Object.find(@image.filename, @@BUCKET).delete
		if AWS::S3::S3Object.exists?(@image.filename, @@BUCKET)
			AWS::S3::S3Object.delete(@image.filename, @@BUCKET)
		end
	else
		logger.debug("image url not from s3: #{@image.url}")
	end
	@image.destroy
	redirect_to '/images'
end

private 
	def sanitize_filename(file_name)
		just_filename = File.basename(file_name)
		just_filename.sub(/[^\w\.\-]/,'_')
	end

	def setup_s3
		@s3_enabled = s3_enabled?
	end

end


##### 
# Code from Obtvse refresh
# keeping it here in case the attempt above doesn't work out.
#  def create
#    @image = Image.create(params[:doc])
#    render :json => {
#      :policy => s3_upload_policy_document,
#      :signature => s3_upload_signature,
#      :key => @image.s3_key,
#      :success_action_redirect => document_upload_success_document_url(@image)
#    }
#  end
#
#  # just in case you need to do anything after the document gets uploaded to amazon.
#  # but since we are sending our docs via a hidden iframe, we don't need to show the user a
#  # thank-you page.
#  def s3_confirm
#    head :ok
#  end
#
#  private
#
#  # generate the policy document that amazon is expecting.
#  def s3_upload_policy_document
#    return @policy if @policy
#    ret = {"expiration" => 5.minutes.from_now.utc.xmlschema,
#      "conditions" =>  [
#        {"bucket" =>  CONFIG['bucket_name']},
#        ["starts-with", "$key", @image.s3_key],
#        {"acl" => "private"},
#        {"success_action_status" => "200"},
#        ["content-length-range", 0, 1048576]
#      ]
#    }
#    @policy = Base64.encode64(ret.to_json).gsub(/\n/,'')
#  end
#
#  # sign our request by Base64 encoding the policy document.
#  def s3_upload_signature
#    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha1'), CONFIG['secret_access_key'], s3_upload_policy_document)).gsub("\n","")
#  end


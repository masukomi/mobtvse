# -*- coding:utf-8 -*-
# There are two tasks here migrate_jekyll and migrate_files
# 
# MIGRATING JEKYLL POSTS
# Usage: rake jekyll:migrate_jekyll[:src_dir, :domain_name]
# Example: rake jekyll:migrate_jekyll['/path/to/_posts', 'www.example.com']
# Please note that the domain name must ONLY be the domain name.
# no http:// no trailing slash. This should be the damoin name 
# you will be hosting it under as posts will have their base url 
# written to include this at the beginning.
#
# This will copy over your posts but NOT any local images...
# 
#
# MIGRATING IMAGES
# Usage: rake jekyll:migrate_files[:images_dir, :absolute_posts_dir, :old_domain_name]
# Example: rake jekyll:migrate_files['/path/to/images/','/Users/me/octopress_blog/source/_posts']
# :images_dir is the diretory containing all of the images and files uploaded
#   to your jekyll / octopress site. It is assumed that this directory is served from the root of your blog.
#   So path/to/images is assumed to be equivalent to http://example.com/images
#   It does not have to be named 'images'
# :absolute_posts_dir is the ABSOLUTE path (from the root of your computer not relative) to your
#   jekyll / octopress posts directory
# :old_domain_name
#   This can be the same as the new domain name.
#   All image urls to files we are uploading to S3 will be rewritten 
#   to point to s3. For example:
#   http://blog.example.com/images/foo.jpg
#   might be rewritten to 
#   http://s3.amazon.com/my_s3_bucket/images/foo.jpg
require 'unidecode'
require 'open3'
require 'iconv'

class String
  def to_utf8
    ::Iconv.conv('UTF-8//IGNORE', 'UTF-8', self + ' ')[0..-2]
  end
end

namespace :jekyll do
		task :migrate_files, [:images_dir, :absolute_posts_dir, :old_domain_name] => :environment do |cmd, args|
			BUCKET = CONFIG['s3']['image_bucket_name']

			def s3_enabled?
				if CONFIG.has_key?('s3') and CONFIG['s3'].has_key?('enabled')
					if CONFIG['s3']['image_bucket_name'] and CONFIG['s3']['access_key_id'] and CONFIG['s3']['secret_access_key']
						return CONFIG['s3']['enabled']
					end
				end
				return false
			end

			def get_content_type(filename)
				content_type = nil
				extension =	filename.downcase.sub(/.*\.(\w+)$/, '\1')
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
				return content_type
			end

			def upload(directory_name, today, args)
				puts "cding to #{directory_name}/.."
				Dir.chdir "#{directory_name}/.."
				puts "now at #{Dir.pwd}"
				end_dir = directory_name.sub(/.*\/(\w+)\/?/, '\1')
				old_domain = args[:old_domain_name].gsub('.', '\.')
				
				files_to_test = Dir["#{end_dir}/**/*"]
				puts "#{files_to_test.size()} files and directories were found"
				files_to_test.each_with_index do |filename, idx|
					puts "#{idx}) considering #{filename}"
					end_file = filename.sub(/.*\/(\S+?)$/, '\1')
					#puts "end_file: #{end_file}"
					unless File.directory? filename
						used_in = `grep #{end_file} #{args[:absolute_posts_dir]}/* | grep -v ':0'`
						if (used_in.length() > 0) # S3 costs money, so only upload the ones that are used
							content_type = get_content_type(filename)
#							puts "uploading: #{filename} w/ content-type: #{content_type} | #{File.ctime(filename)}"
							c_time = File.ctime(filename) rescue nil
							if (! AWS::S3::S3Object.exists? filename, BUCKET  )
								AWS::S3::S3Object.store(filename, File.open(filename), BUCKET, :content_type => content_type, :access => :public_read)
								url = AWS::S3::S3Object.url_for(filename, BUCKET, :authenticated => false)
								@file = nil
								if content_type.match(/^image\//i)
									@file = Image.new(:title=>end_file, :filename=>filename, :url=>url, :content_type=>content_type, :uploaded_on => c_time ? c_time : today )
								else
									@file = BinaryFile.new(:title=>end_file, :filename=>filename, :url=>url, :content_type=>content_type, :uploaded_on => c_time ? c_time : today)
								end
								@file.save()
								# NOW, update any links to this image
								used_in = used_in.split(/\n/).map{|path| path.sub(/(.*?):.*$/, '\1')}
								
								used_in.each do |path|
									puts "\treplacing (https?://|/)#{filename.gsub('/', '\\/')} with #{url}"
									puts "\tin        #{path}"
									new_file_content= []
									File.open(path, 'r') do |f|
										f.each_line{|line| 
											new_file_content << line.gsub(/(https?:\/\/#{old_domain}\/|\/)(#{filename.gsub('/', '\\/')})/, url)
										}
									end
									File.open(path, "w") {|file| file.puts new_file_content.join('')}
								end
							else
								unless(@attempted_download)
									begin
										# there's a bug in Amazon's .exists? test.
										# if your credentials are bad it'll tell you exists no matter what.
										# You must attempt to access the file to be sure it's correct.
										file = AWS::S3::S3Object.find filename, BUCKET
									rescue => e
										puts "PROBLEM WITH S3: #{e}"
										exit(1)
									end
									@attempted_download = true
								end
								puts "SKIPPING #{filename}: it's already in S3's #{BUCKET} bucket: #{AWS::S3::S3Object.exists?( filename, BUCKET).inspect }"
							end
						else
							puts "\tSKIPPING unused file: #{filename}"
						end
					end
				end
			end

			puts "args: #{args.inspect}"
			unless args[:images_dir]
				raise "you must specify an images directory.\nrake jekyll:migrate_files['/path/to/imaes', '/Users/me/octopress_blog/source/_posts', 'www.example.com']"
			end
			unless args[:absolute_posts_dir]
				raise "you must specify an absolute path to your posts.\nrake jekyll:migrate_files['/path/to/imaes', '/Users/me/octopress_blog/source/_posts', 'www.example.com']"
			end
			unless args[:old_domain_name]
				raise "you must specify your old domain name.\nrake jekyll:migrate_files['/path/to/imaes', '/Users/me/octopress_blog/source/_posts', 'www.example.com']"
			end

			if (s3_enabled?)
				
				if (File.exists? args[:images_dir])
					
					upload(args[:images_dir], Date.today, args)
				else
					puts "#{args[:images_dir]} doesn't exist"
				end
			else
				puts "S3 has not been configured in config/config.yml. Can't upload"
				exit 1
			end

		end

#############################################
		task :migrate_jekyll, [:src_dir, :domain_name] => :environment do |cmd, args|

				# Ingest a Jekyll style Markdown file
				# returns a hash containing :metadata and :content
				def read_yaml(file_path)
					content = File.read(file_path)
					data = {}
					begin
						if content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
							content = content.sub(/^(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m, '\3')
							data = YAML.load($1)
						end
					rescue => e
						puts "YAML Exception reading #{name}: #{e.message}"
					end

					return {:metadata => data, :content=>content}
				end

				# creates a jekyll style slug
				def jekyll_sluggify( title )
					begin
						require 'unidecode'
						title = title.to_ascii
					rescue LoadError
						STDERR.puts "Could not require 'unidecode'. If your post titles have non-ASCII characters, they may not match up to what Jekyll created for you."
						STDERR.puts "\ttitle affected: #{title}"
					end
					return title.downcase.gsub(/[^0-9A-Za-z]+/, " ").strip.gsub(" ", "-")
				end



				unless args[:src_dir]
					raise "you must specify a source ( _posts ) directory.\nrake jekyll:migrate_jekyll['/path/to/_posts', 'development']"
				end
				unless args[:domain_name]
					raise "You must specify a domain name. See documentation."
				end
				src_dir = args[:src_dir].sub(/\/$/, '')

				Dir.glob("#{src_dir}/**/*.markdown") do |post_file|

					begin 
						next if File.directory? post_file
						#puts "working on: #{post_file}"

						post_info = read_yaml(post_file)
						data = post_info[:metadata]
						content = post_info[:content]

						slug = data['slug']
						unless slug
							puts "NOTE: this file had no slug. creating one: #{post_file}"
							slug = jekyll_sluggify(data['title'])
						end
						unless slug
							puts "WARNING: unable to create slug for this file. Skipping: #{post_file}"
						end

						# Slugs are unique, as such, we can test if this has already been imported
						# and skip it if it has.
						post_count = Post.where(:slug=>slug).count
						if post_count > 0
							#puts "Skipping '#{slug}' There's already a post with that slug"
							next
						end


						tags = data['tags'] || []
						categories = data['tags'] || []
						categories_tags = tags | categories
						draft = data.has_key?('published') ? (! data['published']) : nil #published should be set to false or true
						draft = false if draft.nil?
							# if its not present it is assumed to be published

						# cleanup date format missing seconds
						unless data['date']
							puts "WARNING: #{post_file} had no date! Skipping"
							next
						end
						date = nil
						if (data['date'].instance_of? Time)
							date = data['date']
						else
							data['date'].sub!(/(\d{4}-\d{2}-\d{2} )(\d{1})(:\d{2})/, ('\1' + '0\2\3'))
							data['date'].sub!(/(\d{4}-\d{2}-\d{2} \d{2}:\d{2})$/, ('\1' + ':00'))
							date = DateTime.strptime(data['date'], '%Y-%m-%d %H:%M:%S')
							date = DateTime.parse(data['date']) if date.nil?
						end
						url_format_string = "http://#{args[:domain_name]}#{CONFIG['post_url_style']}"
						url = date.strftime(url_format_string)
						url.gsub!(':slug', slug)

						post = Post.create!( 
								:title => data['title'].to_utf8(),
								:meta_description => (data['description'] ? data['description'] : nil),
								:tags => categories_tags.join(','), # tags go in as a comma delimited string
								:draft=> draft,
								:slug => slug,
								:page => false,
								:url => url,
								:created_at => date,
								:updated_at => date,
								:posted_at => draft ? nil : date,
								:comments_enabled=>true,
								:kudos => 0,
								:content => content.to_utf8()
						)
					rescue => e
						
						$stderr.puts("WARNING, FAILED IMPORT: #{post_file}\n#{e.message}")
						$stderr.puts("raw_date: #{data['date']}, parsed date: #{date.inspect}") if e.message.match(/invalid date/)
						$stderr.puts("post metadata: #{post_info[:metadata].inspect}")
					end
				end
		end
end

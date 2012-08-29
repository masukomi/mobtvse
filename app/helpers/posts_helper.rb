module PostsHelper
	def reading_time(word_count)
		#wc | awk '{printf "%d:%02d", int($2/250), int($2%250/250*60)}'
		minutes = word_count / 250
		hours = minutes > 60 ? minutes / 60 : 0
		seconds = word_count % 250 / 250 * 60
		#"%02d:%02d:%02d" % [ hours, minutes, seconds ]
		return "~#{minutes}m #{seconds}s"
	end

	def comments_viewable?(single_post, post)
		return (CONFIG['disqus_enabled'] and not localhost? and single_post and post.comments_enabled? and not post.draft? and not post.page? )
	end
end


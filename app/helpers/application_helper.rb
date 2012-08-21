module ApplicationHelper
  def is_admin?
    true if session[:admin] == true
  end

  def markdown(text)
    text = youtube_embed(text)
    text = gist_embed(text)
    RedcarpetCompat.new(text, :fenced_code, :gh_blockcode)
  end

  # TODO refactor these filters so they don't each iterate over all the lines
  def gist_embed(str)
    output = str.lines.map do |line|
      match = nil
      match = line.match(/\{\{gist\s+(.*)\}\}/)
      match ? "<div id=\"#{match[1]}\" class=\"gist\">Loading gist...</div>" : line
    end
    output.join
  end

  def youtube_embed(str)
  	output = str.lines.map do |line|
  		match = nil
  		match = line.match(/^http.*(?:youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=)([^#\&\?]*).*/)
  		match ? render(:partial => 'youtube', :locals => { :video => match[1] }) : line
  	end
  	output.join
  end

  def permalink_path_for(post, include_domain=true)
	if post.permalinkable?
		if not post.page?
			date_plus_slug = post.posted_at.strftime(CONFIG['post_url_style']).gsub(':slug', post.slug)
			return "#{ include_domain ? (localhost? ? 'http://localhost:3000' : CONFIG['canonical_url']) : ''}#{date_plus_slug}"
		else
			return post.slug
		end
	else
    	logger.error("Can't permalink to drafts (post #{post.id})")
		return "#" 
		# it's the only valid url we can return without blowing up
	end
  end
  def localhost?
    return request.url.match(/localhost|0\.0\.0\.0|127\.0\.0\.1/) ? true : false
  end
  def graph_kudos(posts, options = {:width=>'380px', :height=>'50px'})
    options = {:include_internal=>true, :edit_link=>false}.merge(options) #override defaults
    flexgraph_data = []
    max_kudos = posts.max_by {|p| p.kudos }
logger.debug("max_kudos.kudos: #{max_kudos.kudos}")
    one_pct = max_kudos.kudos / 100
    one_pct = 1 if one_pct < 1
    posts.each do | post |
      p_kudo_pct = ( post.kudos / one_pct)
      link = nil
      if (options[:edit_link])
        link=edit_post_path(post.id)
      else
        if post.external? or options[:include_internal]
          if ! post.draft?
            link = permalink_path_for(post, false)
          else
            link = "/posts/#{post.id}"
          end
        end
      end
      flexgraph_data << [p_kudo_pct, link, post.title]
    end
    logger.debug("flexgraph_data: #{flexgraph_data.inspect}")
    render :partial => 'shared/flexgraph', :locals=>{:bars=>flexgraph_data, :width=>options[:width], :height=>options[:height]}
  end
end

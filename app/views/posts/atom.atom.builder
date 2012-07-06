atom_feed do |feed|
  feed.title CONFIG['title']
  feed.updated (@posts.size() > 0 ? @posts.first.created_at : DateTime.now)

  @posts.each do |post|
    feed.entry post do |entry|
      entry.title post.title
      if post.content
          entry.content markdown(post.content).to_html, :type => 'html'
      else
          entry.content "<p>No content</p>", :type=>'html'
      end
      #entry.content post.body, :type => 'html'

      entry.author do |author|
        author.name CONFIG['name']
      end
    end
  end
end

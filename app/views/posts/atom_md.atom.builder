atom_feed({:url=>"#{CONFIG['canonical_url']}/atom.xml", :root_url=>CONFIG['canonical_url'] }) do |feed|
  feed.title CONFIG['title']
  feed.updated (@posts.size() > 0 ? @posts.first.created_at : DateTime.now)

  @posts.each do |post|
    feed.entry( post, :url=> permalink_path_for(post, true), :published=>post.posted_at, :updated=>post.updated_at) do |entry|
      entry.title post.title
      if post.content
          entry.content post.content, :type=>'text', :markup=>'markdown'
      else
          entry.content "# No content", :type=>'text', :markup=>'markdown'
      end

      entry.author do |author|
        author.name CONFIG['name']
      end
    end
  end
end

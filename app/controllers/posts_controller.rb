class PostsController < ApplicationController

  ##################
  ## TODO NOTES
  ## the .page functionality that needs reimplementing
  ## is a scope added to the model by the kaminari gem
  ##################

  before_filter :authenticate, :except => [:index, :show, :update_kudo, :tag, :archive, :atom, :atom_md]
  layout :choose_layout

  def index
    response.headers['Cache-Control'] = "public, max-age=#{CONFIG['page_cache_length'] || 300}"
    #TODO reimplement paging mongo style
    all_posts = nil
    now = DateTime.now
    unless params[:tag]
      all_posts = Post.all(conditions: {:draft=>false, :page=>false, :posted_at=>{"$lte"=>now}},:sort=> [[ :posted_at, :desc ]]).entries
    else
      all_posts = Post.any_in(:tags_array => [params[:tag]]).where(:posted_at=>{"$lte"=>now}, :page=>false).desc(:posted_at).entries
    end
    @posts = Kaminari.paginate_array(all_posts).page(params[:page]).per(CONFIG['posts_on_index'] ? CONFIG['posts_on_index'] : 5 )
    @pages = Post.reverse_chron.where(:draft=>false, :page=>true).entries
    respond_to do |format|
      format.html
      format.xml { render :xml => @posts }
      format.rss { render :layout => false }
      format.atom { render :layout => false }
    end
  end
  
  def atom
    response.headers['Cache-Control'] = "public, max-age=#{CONFIG['page_cache_length'] || 300}"
    all_posts = nil
    now = DateTime.now
    max = CONFIG['posts_in_feed'] || 20
    @posts = Post.all(conditions: {:draft=>false, :page=>false, :posted_at=>{"$lte"=>now}},:sort=> [[ :posted_at, :desc ]]).limit(max).entries
    respond_to do | format |
      format.atom{render :layout => false} 
    end
  end
  alias :atom_md :atom

  def tag
    response.headers['Cache-Control'] = "public, max-age=#{CONFIG['page_cache_length'] || 300}"
    @tag = params[:id]
    now = DateTime.now
    @posts = Post.any_in(:tags_array => [@tag]).where(:posted_at=>{"$lte"=>now}, :page=>false).desc(:posted_at).entries
      # we don't want a paginated list here
    #logger.debug("#{@posts.size} posts were found with tag #{@tag}")
    respond_to do |format|
      format.html
    end
  end
  def archive
    response.headers['Cache-Control'] = "public, max-age=#{CONFIG['page_cache_length'] || 300}"
    #TODO
    # - create a @months var where each entry has a list of posts
    #   posts would be sorted by date (reverse, or forward chronological)
    #   @months[0].posts = [<#Post>, <#Post>]

    @pages = Post.reverse_chron.where(:draft=>false, :page=>true).entries
    @published_tags_with_weight = Post.published_tags_with_weight()
    @most_loved = Post.loved.limit(10)
    #@tags_with_weight = Post.tags_with_weight
    #TODO fix this so that it goes all the way back to the first post
    @months = []
    if (Post.count > 0)
      first_post_date = Post.where(:draft=>false, :page=>false).order_by(:posted_at=>:asc).first.posted_at
      first_of_month=Date.today.at_beginning_of_month.at_beginning_of_day
      month = Month.new(first_of_month)
      if (month.start <= first_post_date)
        @months << month
      else
        while (month.start >= first_post_date)
          @months << month
          month = month.previous()
        end
        @months << month
          # it's already had .previous() called on it
          # the month whose start isn't after the first post
      end
    end
  end

  def preview
    @post = Post.new(params[:post])
    @preview = true
    respond_to do |format|
      format.html { render 'show' }
    end
  end

  def admin
    response.headers['Cache-Control'] = 'no-cache'
    @no_header = true
    @placeholder_post = Post.new
    #todo re-implement the paging mongoid style
    all_published = nil
    booleanify_params(params)
    unless params[:tag]
      if (not params[:by_kudos])
        all_published = Post.where(:draft=>false, :page=>false).order_by(:posted_at=>:desc).entries
      else
        all_published = Post.loved.entries
      end
    else
      all_published = Post.any_in({:tags_array => [params[:tag]]}).descending(:posted_at).entries
      #BUG, this will currently include static pages
    end
    @tags = Post.published_tags #Post.tags_with_weight returns [['foo', 2],['bar', 1],['baz', 3]]
    @published = Kaminari.paginate_array(all_published).page(params[:post_page]).per(20)
    @drafts = Kaminari.paginate_array(Post.where(:draft=>true).entries).page(params[:draft_page]).per(20)
      # @drafts includes unpublished pages
    @pages = Kaminari.paginate_array(Post.reverse_chron.where(:draft=>false, :page=>true).entries).page(params[:post_page]).per(20)
      # @pages does not include unpublished pages. see @drafts
    respond_to do |format|
      format.html
    end
  end

  def show
    response.headers['Cache-Control'] = "public, max-age=#{CONFIG['page_cache_length'] || 300}"
    @single_post = true
    @post = nil
    if (params[:slug])
      @post = admin? ? Post.first(conditions: {slug: params[:slug]}) : Post.first(conditions: {slug: params[:slug],  draft: false})
    elsif admin?
logger.debug("NO SLUG + ADMIN")
      @post = Post.find(params[:id]) #must be a draft
    end

    @pages = Post.reverse_chron.where(:draft=>false, :page=>true).entries
    # we want pages before the 404 because it's in the header
    render_404 and return if @post.nil?

    unless @post.meta_description.blank?
      @meta_description = @post.meta_description
    end
    respond_to do |format|
      if @post.present?
        format.html
        format.xml { render :xml => @post }
      else
        format.any { head status: :not_found  }
      end
    end
  end

  def new
    @no_header = true
    #TODO reimplement paging mongo style
    @posts = Post.all.entries
    #@posts = Post.page(params[:page]).per(20)
    @post = Post.new

    respond_to do |format|
      format.html
      format.xml { render xml: @post }
    end
  end

  def get
    @post = Post.find(params[:id])
    render :text => @post.to_json
  end

  def edit
    response.headers['Cache-Control'] = 'no-cache'
    @no_header = true
    @post = Post.find(params[:id])
    @current_month = Month.new(Date.today)
    respond_to do |format|
      format.html
      format.json { render :json => @post }
    end
  end

  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to "/edit/#{@post.id}", :notice => "Post created successfully" }
        format.xml { render :xml => @post, :status => :created, location: @post }
        format.text { render :text => @post.to_json }
      else
        format.html { render :action => 'new' }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity}
        format.text { head :bad_request }
      end
    end
  end

  def update
    @post = Post.find(params[:id])
    #@post = Post.first(conditions: {slug: params[:slug]})
    booleanify_params(params)
    respond_to do |format|
      if @post.update_attributes(params[:post])

        format.html { redirect_to "/edit/#{@post.id}", :notice => "Post updated successfully" }
        format.xml { head :ok }
        format.text{ render :text => @post.to_json}
      else
        format.html { render :action => 'edit' }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity}
        format.text { head :bad_request }
      end
    end
  end

  def update_kudo
    # if an admin futzes with the kudos on the page
    # it will trigger the animation but not 
    # actually update the count.
    unless session[:admin] == true
      @post = Post.find(params[:id])
      @post.kudos +=1
      @post.save()
    end
    render :nothing=>true
  end

  def destroy
    @post = Post.first(conditions: {_id: params[:id]})
    if (@post)
      @post.destroy
    else
      logger.warn("couldn't find post '#{params[:id]}' for deletion")
    end

    respond_to do |format|
      format.html { redirect_to '/admin' }
      format.xml { head :ok }
    end
  end

  private

  def admin?
    session[:admin] == true
  end

  def booleanify_params(params)
    Post.get_boolean_fields.each do |param|
      if params[param] == '1' or params[param] == 'true'
        params[param] = true
      else
        params[param] = false
      end
    end
  end

  def choose_layout
    if ['admin', 'new', 'edit', 'create'].include? action_name
      'admin'
    else
      'application'
    end
  end

  def render_404
    response.headers['Cache-Control'] = "public, max-age=#{CONFIG['page_cache_length'] || 600}"
    respond_to do |format|
      format.html { render 'shared/404', :status => :not_found, :layout=>'status_pages' }
      format.xml  { head :not_found , :layout=>false}
      format.any  { head :not_found , :layout=>false}
    end
  end
  
end

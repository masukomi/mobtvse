class PostsController < ApplicationController

  ##################
  ## TODO NOTES
  ## the .page functionality that needs reimplementing
  ## is a scope added to the model by the kaminari gem
  ##################

  before_filter :authenticate, :except => [:index, :show]
  layout :choose_layout

  def index
    #TODO reimplement paging mongo style
    @posts = Kaminari.paginate_array(Post.all(conditions: {draft:false}).entries).page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.xml { render :xml => @posts }
      format.rss { render :layout => false }
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
    @no_header = true
    @post = Post.new
    #todo re-implement the paging mongoid style
    @published = Kaminari.paginate_array(Post.all(conditions: {draft: false}).entries).page(params[:post_page]).per(20)
    @drafts = Kaminari.paginate_array(Post.all(conditions: {draft: true}).entries).page(params[:draft_page]).per(20)
    logger.debug("Published: #{@published.inspect}")
    logger.debug("Drafts: #{@drafts.inspect}")
    respond_to do |format|
      format.html
    end
  end

  def show
    @single_post = true
    @post = admin? ? Post.first(conditions: {slug: params[:slug]}) : Post.first(conditions: {slug: params[:slug],  draft: false})

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

  def edit
    @no_header = true
    @post = Post.find(params[:id])
  end

  def create
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to "/edit/#{@post.id}", :notice => "Post created successfully" }
        format.xml { render :xml => @post, :status => :created, location: @post }
      else
        format.html { render :action => 'new' }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity}
      end
    end
  end

  def update
    @post = Post.first(conditions: {slug: params[:slug]})

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to "/edit/#{@post.id}", :notice => "Post updated successfully" }
        format.xml { head :ok }
      else
        format.html { render :action => 'edit' }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @post = Post.first(conditions: {slug: params[:slug]})
    @post.destroy

    respond_to do |format|
      format.html { redirect_to '/admin' }
      format.xml { head :ok }
    end
  end

  private

  def admin?
    session[:admin] == true
  end

  def choose_layout
    if ['admin', 'new', 'edit', 'create'].include? action_name
      'admin'
    else
      'application'
    end
  end
end

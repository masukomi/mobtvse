Obtvse::Application.routes.draw do
  def calculate_posts_view_route(post_url_style)
    match_path = post_url_style.gsub('%Y', ':year').gsub('%m', ':month').gsub('%d', ':day')
    get match_path, :to => 'posts#show', :as  => 'permalink'
  end

  calculate_posts_view_route(CONFIG['post_url_style'])
  resources :posts
  match '/admin', :to => 'posts#admin'
  match '/get/:id', :to => 'posts#get'
  match '/new', :to => 'posts#new'
  match '/edit/:id', :to => 'posts#edit'
  post '/preview', :to => 'posts#preview'
  put '/preview', :to => 'posts#preview'
  get '/archive', :to => 'posts#archive'
  get "/:slug", :to => 'posts#show', :as => 'post'
  delete '/:slug', :to => 'posts#destroy', :as  => 'post'
  put '/:slug', :to => 'posts#update', :as  => 'post'

  match ':controller(/:action(/:id(.:format)))'
  root :to => 'posts#index'
end

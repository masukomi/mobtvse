Rails31App::Application.routes.draw do
  devise_for :users
  root :to => "home#index"
end

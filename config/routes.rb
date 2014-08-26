VanTags::Application.routes.draw do
  resources :vans, except: :show
  root to: 'vans#index'
end

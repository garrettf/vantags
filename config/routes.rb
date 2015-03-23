VanTags::Application.routes.draw do
  resources :vans, except: :show do
    get 'tags', on: :collection
  end
  root to: 'vans#index'
end

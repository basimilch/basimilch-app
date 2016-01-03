Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # This maps HTTP verbs to controller actions automatically.
  # See 'master/README.md#implicit-routing' for more info on routing.
  resources :users
  resources :account_activations, only: [:create, :edit, :update]

  # You can have the root of your site routed with "root"
  root    'sessions#new'

  get     'profile'       => 'users#profile',             as: :profile
  get     'profile/edit'  => 'users#profile_edit',        as: :profile_edit
  patch   'profile'       => 'users#profile_update',      as: :profile_update

  get     'login'         => 'sessions#new',              as: :login
  get     'login/:code'   => 'sessions#create_from_url',  as: :login_direct
  post    'login'         => 'sessions#validation',       as: :login_validation
  put     'login'         => 'sessions#create',           as: :login_create
  delete  'logout'        => 'sessions#destroy',          as: :logout

  get     'signup'        => 'signups#new',               as: :signup
  post    'signup'        => 'signups#validation',        as: :signup_validation
  put     'signup'        => 'signups#create',            as: :signup_create


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

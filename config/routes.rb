Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # This maps HTTP verbs to controller actions automatically.
  # See 'master/README.md#implicit-routing' for more info on routing.
  resources :users
  resources :share_certificates
  resources :jobs
  resources :job_types
  resources :depots
  resources :product_options
  resources :subscriptions

  # You can have the root of your site routed with "root"
  root    'sessions#new'

  post    'users/:id/activate' => 'users#activate',       as: :users_activate

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

  post  'jobs/:id/signup'       => 'jobs#signup_current_user', as: :job_signup
  post  'jobs/:id/signup_users' => 'jobs#signup_users',   as: :job_signup_users
  put   'jobs/:id/cancel_job_signup/:job_signup_id' => 'jobs#cancel_job_signup',
                                                          as: :cancel_job_signup
  put   'jobs/:id/cancel'       => 'jobs#cancel',         as: :job_cancel

  put   'depots/:id/cancel'     => 'depots#cancel',       as: :depot_cancel
  put   'depots/:id/cancel_coordinator/:coordinator_id' =>
          'depots#cancel_coordinator', as: :depot_cancel_coordinator

  put   'product_options/:id/cancel' => 'product_options#cancel',
                                     as: :product_option_cancel

  get   'subscription'       => 'subscriptions#subscription',
                               as: :current_user_subscription
  get   'subscription/edit'  => 'subscriptions#subscription_edit',
                               as: :current_user_subscription_edit
  patch 'subscription'       => 'subscriptions#subscription_update',
                               as: :current_user_subscription_update
  put   'subscriptions/:id/cancel_subscribership/:subscribership_id' =>
          'subscriptions#cancel_subscribership', as: :cancel_subscribership

  get   'depot'              => 'depots#depot', as: :current_user_depot

  get   'subscriptions/lists/production'  => 'subscriptions#production_list',
                                          as: :subscription_production_list

  get   'subscriptions/lists/depots'   => 'subscriptions#depot_lists',
                                             as: :subscription_depot_lists

  # DOC: http://stackoverflow.com/a/26286472/5764181
  # DOC: https://wearestac.com/blog/dynamic-error-pages-in-rails
  # DOC: https://github.com/mirego/gaffe#rails-test-environment
  Rails.configuration.error_codes_with_custom_view.each do |code|
    get "/#{code}", to: 'errors#show', code: code
  end
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

GetMocha::Application.routes.draw do
  #~ devise_for :users
  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
    post "users/sign_in",:to=>"devise/sessions#create",:as=>"user_session"
    get "logout",:to=>"devise/sessions#destroy",:as=>"destroy_user_session"
    post "users/password",:to=>"devise/passwords#create",:as=>"user_password"
    get "users/password/new",:to=>"devise/passwords#new",:as=>"new_user_password"
    get "users/password/edit",:to=>"devise/passwords#edit",:as=>"edit_user_password"
    put "users/password",:to=>"devise/passwords#update"
    post "users",:to=>"devise/registrations#create",:as=>"user_registration"
    get "sign_up",:to=>"devise/registrations#new",:as=>"new_user_registration"
    get "settings-profile",:to=>"devise/registrations#edit",:as=>"edit_user_registration"
    put "users",:to=>"devise/registrations#update"
    delete "users",:to=>"devise/registrations#destroy"    
  end


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

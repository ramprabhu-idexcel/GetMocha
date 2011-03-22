GetMocha::Application.routes.draw do
  
  root :to => "home#index"

  devise_for :users, :controllers => {:registrations => "users",:sessions=>"sessions"}     
  
  devise_scope :user do
    root :to => "devise/registrations#edit"
    get "sign_in", :to => "devise/sessions#new",:as=>"new_user_session"
    get "logout",:to=>"devise/sessions#destroy",:as=>"destroy_user_session"
    get "forgot_password",:to=>"devise/passwords#new",:as=>"new_user_password"
    get "resend_confirmation",:to=>"devise/confirmations#new",:as=>"new_user_confirmation"
    get "change_password",:to=>"devise/passwords#edit",:as=>"edit_user_password"
    get "sign_up",:to=>"devise/registrations#new",:as=>"new_user_registration"
    get "settings-profile",:to=>"devise/registrations#edit",:as=>"edit_user_registration"
    get "create" ,:to=>"devise/projects#create"
  end
 
  resources :projects do 
      collection do
        post 'remove_people'
        post 'add_new'
        post 'update_proj_settings'
        get 'invite_people_settings'
      end
      member do
        post 'settings_pane'
      end
    
  end
  
  resources :updates do
    collection do
      put 'edit_profile'
      put 'edit_password'
      post 'create_secondary_email'
      post 'save_image'
    end
    member do
      delete 'delete_email'
    end
  end
   
  match '/verify/:verification_code'=>'updates#verify_email',:as=>'verify_secondary_email',:method=>:get
  match '/settings' =>'projects#settings', :as => 'project_settings', :method => :post
  match '/projects/verify_email/:verification_code' =>'projects#verify_email', :as => 'verify_email', :method => :post
  match '/projects/join_project/:invitation_code' =>'projects#join_project', :as => 'join_project', :method => :post
  match '/file_download_from_email/:id' =>'projects#file_download_from_email', :as => 'file_download_from_email', :method => :post
  
  #~ match '/:project_id/settings' =>'projects#settings_pane', :as => 'project_settings_pane', :method => :post
  #~ match '/del_people' =>'projects#remove_people', :as=>'remove_people'
  #~ match '/update_proj_settings' =>'projects#update_proj_settings', :as=>'update_proj_settings'
  #~ match '/projects/add_new' =>'projects#add_new', :as=>'add_new'
  
  # Message routes
  
  resources :messages
  match 'all_messages'=>'messages#all_messages',:as=>'all_messages',:method=>:get
  match 'starred_messages'=>'messages#starred_messages',:as=>'starred_messages',:method=>:get
  match 'project/:project_id'=>'messages#project_messages',:as=>'project_messages',:method=>:get
  match 'project/:project_id/:activity_id'=>'messages#show',:as=>'project_message_comment',:method=>:get
  match 'all_messages/:activity_id'=>'messages#show',:as=>'activity_message',:method=>:get
  match 'starred_messages/:activity_id'=>'messages#show',:as=>'activity_message',:method=>:get
  match 'star_message/:activity_id'=>'messages#star_message',:as=>'star_message',:method=>:get
  match 'subscribe/:activity_id'=>'messages#subscribe',:as=>'subscribe_message',:method=>:get
  match 'unsubscribe/:activity_id'=>'messages#unsubscribe',:as=>'unsubscribe_message',:method=>:get
  match 'unsubscribe_via_email/:user_id/:message_id'=>'messages#unsubscribe_via_email',:as=>'unsubscribe_message_via_email',:method=>:post
  match 'messages'=>'messages#destroy',:as=>'delete_message',:method=>:delete
  
  resource :comments
   match '/remove_attach/:id' =>"attachments#remove_attach"

  resource :comments
  resources :attachments do
    member do
      get :remove_attach
    end
  end
  
  match 'faq' =>"home#faq"
  
 match 'terms' =>"home#terms"
 
 match 'privacy' =>"home#privacy"


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

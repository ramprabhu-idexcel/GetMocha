GetMocha::Application.routes.draw do
  root :to => "home#index"
  devise_for :users,:controllers =>{:registrations =>"users",:sessions=>"sessions",:confirmations=>"confirmation",:passwords=>"passwords"}
  devise_scope :user do
    root :to => "devise/registrations#edit"
    get "signin", :to => "devise/sessions#new",:as=>"new_user_session"
    get "logout",:to=>"devise/sessions#destroy",:as=>"destroy_user_session"
    get "forgot_password",:to=>"devise/passwords#new",:as=>"new_user_password"
    get "resend_confirmation",:to=>"devise/confirmations#new",:as=>"new_user_confirmation"
    get "change_password",:to=>"passwords#edit",:as=>"edit_user_password"
    get "signup",:to=>"devise/registrations#new",:as=>"new_user_registration"
    get "settings-profile",:to=>"devise/registrations#edit",:as=>"edit_user_registration"
    get "create" ,:to=>"devise/projects#create"
end
  get "admin_panel" =>'admins#new'
  post "admin_pasword_reset"=>'admins#reset_password', :as=>:admin_pswd_change
  get "admin_settings"=>'admins#settings', :as=>:admin_page
  get "admins/users"=>'admins#users'
  get "admins/projects"=>'admins#projects'
  get "admins/analetics"=>'admins#analetics'
 devise_for :admins, :controllers =>{ :sessions=>"admin_sessions",:passwords=>"admin_passwords"}
 devise_scope :admin do
 get "admin_change_password",:to=>"admin_passwords#edit",:as=>"edit_admin_password"
 end
 resources :admins do
      member do
      post 'remove_user'
      post 'remove_project'
  end
  end
  resources :projects do
    member do
      get 'settings_pane'
    end
    collection do
      post 'remove_people'
      post 'add_new'
      post 'update_proj_settings'
      get 'invite_people_settings'
      post 'invite_people'
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
  match  '/home/email_reply' =>'home#check_email_reply_and_save', :method => :post
  # Message routes
  resources :messages
  match 'all_messages'=>'messages#all_messages',:as=>'all_messages',:method=>:get
  match 'starred_messages'=>'messages#starred_messages',:as=>'starred_messages',:method=>:get
  match 'project/:project_id'=>'messages#project_messages',:as=>'project_messages',:method=>:get
  match 'project/:project_id/:activity_id'=>'messages#show',:as=>'project_message_comment',:method=>:get
  match 'all_messages/:activity_id'=>'messages#show',:as=>'activity_message',:method=>:get

  match 'starred_messages/:activity_id'=>'messages#show',:as=>'activity_starred_message',:method=>:get
  match 'star_message/:activity_id'=>'activities#star_message',:as=>'star_message',:method=>:get
  match 'subscribe/:activity_id'=>'activities#subscribe',:as=>'subscribe_activity',:method=>:get
  match 'unsubscribe/:activity_id'=>'messages#unsubscribe',:as=>'unsubscribe_message',:method=>:get
  match 'unsubscribe_via_email/:user_id/:message_id'=>'messages#unsubscribe_via_email',:as=>'unsubscribe_message_via_email',:method=>:post
  match 'unsubscribe_via_email_task/:user_id/:message_id'=>'tasks#unsubscribe_via_email_task',:as=>'unsubscribe_message_via_email_task',:method=>:post
  match 'messages'=>'messages#destroy',:as=>'delete_message',:method=>:delete
  resource :comments
  match '/remove_attach/:id' =>"attachments#remove_attach"
  resources :attachments do
    member do
      get :remove_attach
    end
  end
  #~ # task routes
  resources :tasks do
    member do
      get :project_tasklists
      put :assign_task
      end
    collection do
      put :complete_task
      get :all_tasks
      get :starred_tasks
      get :completed_tasks
      get :my_tasks
    end
  end
  match 'tasks/task_comment/:activity_id'=>'tasks#task_comments',:as=>'task_comments',:method=>:get
  match 'unsubscribe_task_email/:user_id/:task_id'=>'activities#unsubscribe',:as=>'unsubscribe',:method=>:get
  resources :activities
  resources :task_lists
  resources :chats do
    collection do
      post :subscribe
      post :unsubscribe
       get :invite_chat_settings
    end
  end
  match 'chats/:project_id/project_chat'=>'chats#project_chat',:as=>'project_chats',:method=>:get
  match 'popout-chat/:project_id'=>'chats#popout_chat',:as=>'popout_chat',:method=>:get
  match 'load_more/:project_id'=>'chats#load_more',:as=>'load_more',:method=>:get
  match 'chat_invite/:project_id'=>'chats#chat_invite',:as=>'chat_invite',:method=>:get
  match 'faq' =>"home#faq"
  match 'terms' =>"home#terms"
  match 'privacy' =>"home#privacy"
  match 'help' =>"home#help"
  match 'email' =>"home#email"
  match '/home/images'=>"home#images"
  match '/home/contact_via_email'=>"home#contact_via_email"
  match '*a', :to => 'errors#routing'
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

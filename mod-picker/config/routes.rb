Rails.application.routes.draw do
  # disable registration
  devise_for :users, :controllers => { :registrations => "registrations" }
  
  # require authentication before allowing user to access any resources
  authenticate :user do
    resources :games
    resources :categories
    resources :category_priorities
    resources :comments
    resources :install_order_notes
    resources :load_order_notes
    resources :compatibility_notes
    resources :mod_version_compatibility_notes
    resources :mod_list_compatibility_notes
    resources :mod_list_install_order_notes
    resources :mod_list_load_order_notes
    resources :agreement_marks
    resources :incorrect_notes
    resources :helpful_marks
    resources :agreement_marks
    resources :reviews
    resources :mod_authors
    resources :mod_list_stars
    resources :mod_stars
    resources :reputation_links
    resources :user_reputations
    resources :user_settings
    resources :user_bios
    resources :mod_list_mods
    resources :mod_list_custom_plugins
    resources :mod_list_plugins
    resources :mod_lists
    resources :plugin_record_groups
    resources :override_records
    resources :masters
    resources :plugins
    resources :mod_version_files
    resources :mod_asset_files
    resources :mod_versions
    resources :mods
    resources :lover_infos
    resources :workshop_infos
    resources :nexus_infos
    resources :users

    # record groups
    resources :record_groups, only: [:index]

    # angular
    resources :angular, only: [:index]
  end

  # welcome page
  resources :welcome, only: [:index]

  # contact us and subscribe
  match '/contacts', to: 'contacts#new', via: 'get'
  resources :contacts, only: [:new, :create]

  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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

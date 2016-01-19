Rails.application.routes.draw do
  resources :mods
  resources :mods
  resources :lover_infos
  resources :workshop_infos
  resources :nexus_infos
  resources :mods
  resources :games
  resources :category_priorities
  resources :categories
  resources :mod_list_compatibility_notes
  resources :mod_list_installation_notes
  resources :agreement_marks
  resources :incorrect_notes
  resources :helpful_marks
  resources :user_comments
  resources :mod_list_comments
  resources :mod_comments
  resources :compatibility_notes
  resources :installation_notes
  resources :reviews
  resources :comments
  resources :user_mod_author_maps
  resources :user_mod_list_star_maps
  resources :user_mod_star_maps
  resources :mod_list_mods
  resources :mod_list_custom_plugins
  resources :mod_list_plugins
  resources :mod_lists
  resources :plugin_record_groups
  resources :plugin_override_maps
  resources :masters
  resources :plugins
  resources :mod_version_file_maps
  resources :mod_asset_files
  resources :mods
  resources :lover_infos
  resources :workshop_infos
  resources :nexus_infos
  resources :user_mod_author_maps
  resources :user_mod_list_star_maps
  resources :user_mod_star_maps
  resources :mod_list_mods
  resources :mod_list_custom_plugins
  resources :mod_list_plugins
  resources :mod_lists
  resources :plugin_record_groups
  resources :plugin_override_maps
  resources :masters
  resources :plugins
  resources :mod_version_file_maps
  resources :mod_asset_files
  resources :mods
  resources :lover_infos
  resources :workshop_infos
  resources :nexus_infos
  resources :mod_list_compatibility_notes
  resources :mod_list_installation_notes
  resources :agreement_marks
  resources :incorrect_notes
  resources :helpful_marks
  resources :user_comments
  resources :mod_list_comments
  resources :mod_comments
  resources :compatibility_notes
  resources :installation_notes
  resources :reviews
  resources :comments
  resources :user_mod_author_maps
  resources :user_mod_list_star_maps
  resources :user_mod_star_maps
  resources :mod_list_mods
  resources :mod_list_custom_plugins
  resources :mod_list_plugins
  resources :mod_lists
  resources :plugin_record_groups
  resources :plugin_override_maps
  resources :masters
  resources :plugins
  resources :mod_version_file_maps
  resources :mod_asset_files
  resources :mods
  resources :lover_infos
  resources :workshop_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :workshop_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :mod_list_compatibility_notes
  resources :mod_list_installation_notes
  resources :agreement_marks
  resources :incorrect_notes
  resources :helpful_marks
  resources :user_comments
  resources :mod_list_comments
  resources :mod_comments
  resources :compatibility_notes
  resources :installation_notes
  resources :reviews
  resources :comments
  resources :user_mod_author_maps
  resources :user_mod_list_star_maps
  resources :user_mod_star_maps
  resources :mod_list_mods
  resources :mod_list_custom_plugins
  resources :mod_list_plugins
  resources :mod_lists
  resources :plugin_record_groups
  resources :plugin_override_maps
  resources :masters
  resources :masters
  resources :plugins
  resources :mod_version_file_maps
  resources :mod_asset_files
  resources :mods
  resources :lover_infos
  resources :workshop_infos
  resources :nexus_infos
  resources :nexus_infos
  resources :mod_list_compatibility_notes
  resources :mod_list_installation_notes
  resources :agreement_marks
  resources :incorrect_notes
  resources :helpful_marks
  resources :user_comments
  resources :mod_list_comments
  resources :mod_comments
  resources :compatibility_notes
  resources :installation_notes
  resources :reviews
  resources :comments
  resources :user_mod_author_maps
  resources :user_mod_list_star_maps
  resources :user_mod_star_maps
  resources :reputation_maps
  resources :mod_list_mods
  resources :mod_list_custom_plugins
  resources :mod_list_plugins
  resources :mod_lists
  resources :plugin_record_groups
  resources :plugin_override_maps
  resources :masters
  resources :plugins
  resources :mod_version_file_maps
  resources :mod_asset_files
  resources :mods
  resources :lover_infos
  resources :workshop_infos
  resources :nexus_infos
  resources :plugins
  resources :user_reputations
  resources :user_reputations
  resources :user_settings
  resources :user_bios
  devise_for :users
  resources :mod_list_compatibility_notes
  resources :mod_list_installation_notes
  resources :agreement_marks
  resources :incorrect_notes
  resources :helpful_marks
  resources :user_comments
  resources :mod_list_comments
  resources :mod_comments
  resources :compatibility_notes
  resources :installation_notes
  resources :reviews
  resources :comments
  resources :user_mod_author_maps
  resources :user_mod_list_star_maps
  resources :user_mod_star_maps
  resources :reputation_maps
  resources :users
  resources :user_reputations
  resources :user_settings
  resources :user_bios
  resources :mod_list_mods
  resources :mod_list_custom_plugins
  resources :mod_list_plugins
  resources :mod_lists
  resources :plugin_record_groups
  resources :plugin_override_maps
  resources :masters
  resources :plugins
  resources :mod_version_file_maps
  resources :mod_asset_files
  resources :mod_versions
  resources :mods
  resources :lover_infos
  resources :workshop_infos
  resources :nexus_infos
  
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

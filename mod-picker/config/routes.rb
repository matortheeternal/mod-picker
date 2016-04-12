Rails.application.routes.draw do
  # disable registration
  devise_for :users, :controllers => { :registrations => "registrations", :invitations => "user_invitations" }
  
  # require authentication before allowing user to access any resources
  authenticate :user do
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

    # helpful marks
    match '/reviews/:id/helpful', to: 'reviews#helpful', via: 'post'
    match '/compatibility_notes/:id/helpful', to: 'compatibility_notes#helpful', via: 'post'
    match '/install_order_notes/:id/helpful', to: 'install_order_notes#helpful', via: 'post'
    match '/load_order_notes/:id/helpful', to: 'load_order_notes#helpful', via: 'post'

    # agreement marks
    match '/incorrect_notes/:id/agreement', to: 'incorrect_notes#agreement', via: 'post'

    # avatars
    match '/avatar', to: 'avatars#create', via: 'post'

    # static data
    resources :categories, only: [:index]
    resources :category_priorities, only: [:index]
    resources :games, only: [:index]
    resources :quotes, only: [:index]
    resources :record_groups, only: [:index]
    resources :user_titles, only: [:index]

    # angular
    resources :angular, only: [:index]
  end

  # welcome page
  resources :welcome, only: [:index]

  # contact us and subscribe
  match '/contacts', to: 'contacts#new', via: 'get'
  resources :contacts, only: [:new, :create]

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end

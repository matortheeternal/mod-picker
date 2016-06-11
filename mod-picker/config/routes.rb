Rails.application.routes.draw do
  # disable registration
  devise_for :users, :controllers => { :registrations => "registrations", :invitations => "user_invitations" }
  
  # require authentication before allowing user to access any resources
  authenticate :user do
    resources :comments
    resources :install_order_notes
    resources :load_order_notes
    resources :compatibility_notes
    resources :corrections
    resources :reviews
    resources :mod_authors
    resources :user_bios
    resources :mod_asset_files

    # users and user settings
    resources :users, only: [:index, :show, :update, :destroy]
    match '/current_user', to: 'users#current', via: 'get'
    resources :user_settings, only: [:index, :update]
    match '/link_account', to: 'users#link_account', via: 'get'

    # scraping
    resources :nexus_infos, only: [:show, :destroy]
    resources :workshop_infos, only: [:show, :destroy]
    resources :lover_infos, only: [:show, :destroy]

    # tags
    match '/tags', to: 'tags#index', via: 'post'
    match '/tags/:id', to: 'tags#destroy', via: 'delete'
    match '/mods/:id/tags', to: 'mods#update_tags', via: [:patch, :put]
    match '/mod_lists/:id/tags', to: 'mod_lists#update_tags', via: [:patch, :put]

    # mods
    resources :mods, only: [:show, :update, :destroy]
    match '/mods/submit', to: 'mods#create', via: 'post'
    match '/mods', to: 'mods#index', via: 'post'
    match '/mods/search', to: 'mods#search', via: 'post'

    # plugins
    resources :plugins, only: [:show, :destroy]
    match '/plugins', to: 'plugins#index', via: 'post'
    match '/plugins/search', to: 'plugins#search', via: 'post'

    # content associated with mods
    match '/mods/:id/corrections', to: 'mods#corrections', via: 'get'
    match '/mods/:id/reviews', to: 'mods#reviews', via: 'get'
    match '/mods/:id/compatibility_notes', to: 'mods#compatibility_notes', via: 'get'
    match '/mods/:id/install_order_notes', to: 'mods#install_order_notes', via: 'get'
    match '/mods/:id/load_order_notes', to: 'mods#load_order_notes', via: 'get'
    match '/mods/:id/analysis', to: 'mods#analysis', via: 'get'

    # helpful marks
    match '/reviews/:id/helpful', to: 'reviews#helpful', via: 'post'
    match '/compatibility_notes/:id/helpful', to: 'compatibility_notes#helpful', via: 'post'
    match '/install_order_notes/:id/helpful', to: 'install_order_notes#helpful', via: 'post'
    match '/load_order_notes/:id/helpful', to: 'load_order_notes#helpful', via: 'post'

    # hiding content
    match '/reviews/:id/hide', to: 'reviews#hide', via: 'post'
    match '/compatibility_notes/:id/hide', to: 'compatibility_notes#hide', via: 'post'
    match '/install_order_notes/:id/hide', to: 'install_order_notes#hide', via: 'post'
    match '/load_order_notes/:id/hide', to: 'load_order_notes#hide', via: 'post'

    # approving content
    match '/reviews/:id/approve', to: 'reviews#approve', via: 'post'
    match '/compatibility_notes/:id/approve', to: 'compatibility_notes#approve', via: 'post'
    match '/install_order_notes/:id/approve', to: 'install_order_notes#approve', via: 'post'
    match '/load_order_notes/:id/approve', to: 'load_order_notes#approve', via: 'post'

    # agreement marks
    match '/corrections/:id/agreement', to: 'corrections#agreement', via: 'post'

    # mod lists
    resources :mod_lists, only: [:index, :show, :create, :update, :destroy]
    match '/active_mod_list', to: 'mod_lists#active', via: 'get'

    # mod list mods
    match '/mod_lists/:id/mods', to: 'mod_lists#mods', via: 'get'

    # mod list tools
    match '/mod_lists/:id/tools', to: 'mod_lists#tools', via: 'get'

    # mod list plugins
    match '/mod_lists/:id/plugins', to: 'mod_lists#plugins', via: 'get'

    # mod list config files
    match '/mod_lists/:id/config', to: 'mod_lists#configs', via: 'get'

    # mod and mod list stars
    match '/mod_lists/:id/star', to: 'mod_lists#create_star', via: 'post'
    match '/mod_lists/:id/star', to: 'mod_lists#destroy_star', via: 'delete'
    match '/mods/:id/star', to: 'mods#create_star', via: 'post'
    match '/mods/:id/star', to: 'mods#destroy_star', via: 'delete'

    # avatars
    match '/avatar', to: 'avatars#create', via: 'post'

    # static data
    resources :categories, only: [:index]
    resources :category_priorities, only: [:index]
    resources :games, only: [:index]
    resources :quotes, only: [:index]
    resources :record_groups, only: [:index]
    resources :review_sections, only: [:index]
    resources :user_titles, only: [:index]

    # home page
    match '/skyrim', to: 'home#skyrim', via: 'get'
    match '/fallout4', to: 'home#fallout4', via: 'get'
  end

  # welcome page
  resources :welcome, only: [:index]

  # contact us and subscribe
  match '/contacts', to: 'contacts#new', via: 'get'
  resources :contacts, only: [:new, :create]

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end

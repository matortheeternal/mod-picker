Rails.application.routes.draw do
  # disable registration
  devise_for :users, :controllers => { :registrations => "registrations", :invitations => "user_invitations" }

  # require authentication before allowing user to access any resources
  authenticate :user do
    # users
    resources :users, only: [:show, :update, :destroy]
    match '/users/index', to: 'users#index', via: [:get, :post]
    match '/users/search', to: 'users#search', via: [:post]
    match '/current_user', to: 'users#current', via: [:get]

    # user associations
    match '/users/:id/comments', to: 'users#comments', via: [:get, :post]
    match '/link_account', to: 'users#link_account', via: [:get]

    # user reputation_links
    match '/users/:id/rep', to: 'users#endorse', via: [:post]
    match '/users/:id/rep', to: 'users#unendorse', via: [:delete]

    # user settings
    resources :user_settings, only: [:index, :update]

    # scraping
    resources :nexus_infos, only: [:show, :destroy]
    resources :workshop_infos, only: [:show, :destroy]
    resources :lover_infos, only: [:show, :destroy]

    # tags
    match '/tags', to: 'tags#index', via: [:post]
    match '/tags/:id', to: 'tags#destroy', via: [:delete]
    match '/mods/:id/tags', to: 'mods#update_tags', via: [:patch, :put]
    match '/mod_lists/:id/tags', to: 'mod_lists#update_tags', via: [:patch, :put]

    # mods
    resources :mods, only: [:show, :edit, :create, :update, :destroy]
    match '/mods/index', to: 'mods#index', via: [:get, :post]
    match '/mods/search', to: 'mods#search', via: [:post]

    # plugins
    resources :plugins, only: [:show, :destroy]
    match '/plugins', to: 'plugins#index', via: [:post]
    match '/plugins/search', to: 'plugins#search', via: [:post]

    # content associated with mods
    match '/mods/:id/corrections', to: 'mods#corrections', via: [:get, :post]
    match '/mods/:id/reviews', to: 'mods#reviews', via: [:get, :post]
    match '/mods/:id/compatibility_notes', to: 'mods#compatibility_notes', via: [:get, :post]
    match '/mods/:id/install_order_notes', to: 'mods#install_order_notes', via: [:get, :post]
    match '/mods/:id/load_order_notes', to: 'mods#load_order_notes', via: [:get, :post]
    match '/mods/:id/analysis', to: 'mods#analysis', via: [:get, :post]
    match '/mods/:id/image', to: 'mods#image', via: [:post]

    # reviews
    resources :reviews, only: [:show, :create, :update, :destroy]
    match '/reviews/index', to: 'reviews#index', via: [:get, :post]
    match '/reviews/:id/approve', to: 'reviews#approve', via: [:post]
    match '/reviews/:id/hide', to: 'reviews#hide', via: [:post]

    # compatibility notes
    resources :compatibility_notes, only: [:show, :create, :update, :destroy]
    match '/compatibility_notes/index', to: 'compatibility_notes#index', via: [:get, :post]
    match '/compatibility_notes/:id/approve', to: 'compatibility_notes#approve', via: [:post]
    match '/compatibility_notes/:id/hide', to: 'compatibility_notes#hide', via: [:post]
    match '/compatibility_notes/:id/corrections', to: 'compatibility_notes#corrections', via: [:get]
    match '/compatibility_notes/:id/history', to: 'compatibility_notes#history', via: [:get]

    # install order notes
    resources :install_order_notes, only: [:show, :create, :update, :destroy]
    match '/install_order_notes/index', to: 'install_order_notes#index', via: [:get, :post]
    match '/install_order_notes/:id/hide', to: 'install_order_notes#hide', via: [:post]
    match '/install_order_notes/:id/corrections', to: 'install_order_notes#corrections', via: [:get]
    match '/install_order_notes/:id/history', to: 'install_order_notes#history', via: [:get]

    # load order notes
    resources :load_order_notes, only: [:show, :create, :update, :destroy]
    match '/load_order_notes/index', to: 'load_order_notes#index', via: [:get, :post]
    match '/load_order_notes/:id/hide', to: 'load_order_notes#hide', via: [:post]
    match '/install_order_notes/:id/approve', to: 'install_order_notes#approve', via: [:post]
    match '/load_order_notes/:id/corrections', to: 'load_order_notes#corrections', via: [:get]
    match '/load_order_notes/:id/history', to: 'load_order_notes#history', via: [:get]

    # corrections
    resources :corrections, only: [:show, :create, :update, :destroy]
    match '/corrections/index', to: 'corrections#index', via: [:get, :post]
    match '/corrections/:id/hide', to: 'corrections#hide', via: [:post]
    match '/load_order_notes/:id/approve', to: 'load_order_notes#approve', via: [:post]
    match '/corrections/:id/agreement', to: 'corrections#agreement', via: [:post]
    match '/corrections/:id/comments', to: 'corrections#comments', via: [:get, :post]

    # comments
    resources :comments, only: [:show, :create, :update, :destroy]
    match '/comments/index', to: 'comments#index', via: [:get, :post]
    match '/comments/:id/hide', to: 'comments#hide', via: [:post]

    # helpful marks
    match '/reviews/:id/helpful', to: 'reviews#helpful', via: [:post]
    match '/compatibility_notes/:id/helpful', to: 'compatibility_notes#helpful', via: [:post]
    match '/install_order_notes/:id/helpful', to: 'install_order_notes#helpful', via: [:post]
    match '/load_order_notes/:id/helpful', to: 'load_order_notes#helpful', via: [:post]

    # mod lists
    resources :mod_lists, only: [:index, :show, :create, :update, :destroy]
    match '/active_mod_list', to: 'mod_lists#active', via: [:get]
    match '/mod_lists/:id/mods', to: 'mod_lists#mods', via: [:get, :post]
    match '/mod_lists/:id/tools', to: 'mod_lists#tools', via: [:get, :post]
    match '/mod_lists/:id/plugins', to: 'mod_lists#plugins', via: [:get, :post]
    match '/mod_lists/:id/config_files', to: 'mod_lists#config_files', via: [:get, :post]
    match '/mod_lists/:id/comments', to: 'mod_lists#comments', via: [:get, :post]
    match '/mod_list_mods', to: 'mod_list_mods#create', via: [:post]
    match '/mod_list_groups', to: 'mod_list_groups#create', via: [:post]

    # mod and mod list stars
    match '/mod_lists/:id/star', to: 'mod_lists#create_star', via: [:post]
    match '/mod_lists/:id/star', to: 'mod_lists#destroy_star', via: [:delete]
    match '/mods/:id/star', to: 'mods#create_star', via: [:post]
    match '/mods/:id/star', to: 'mods#destroy_star', via: [:delete]

    # avatars
    match '/avatar', to: 'avatars#create', via: [:post]

    # static data
    resources :categories, only: [:index]
    resources :category_priorities, only: [:index]
    resources :games, only: [:index]
    resources :quotes, only: [:index]
    resources :record_groups, only: [:index]
    resources :review_sections, only: [:index]
    resources :user_titles, only: [:index]

    # legal pages
    match '/legal', to: 'legal_pages#index', via: [:get]
    match '/legal/tos', to: 'legal_pages#tos', via: [:get]
    match '/legal/privacy', to: 'legal_pages#privacy', via: [:get]
    match '/legal/copyright', to: 'legal_pages#copyright', via: [:get]

    # home page
    match '/skyrim', to: 'home#skyrim', via: [:get]
    match '/fallout4', to: 'home#fallout4', via: [:get]
    match '/home', to: 'home#index', via: [:get]
  end

  # welcome page
  resources :welcome, only: [:index]

  # contact us and subscribe
  match '/contacts', to: 'contacts#new', via: [:get]
  resources :contacts, only: [:new, :create]

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end

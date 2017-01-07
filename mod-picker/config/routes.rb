Rails.application.routes.draw do
  # disable registration
  devise_for :users, :controllers => {
      sessions: 'sessions',
      registrations: 'registrations',
      invitations: 'user_invitations'
  }
  devise_scope :user do
    get '/users/invitation/batch/new' => 'user_invitations#new_batch'
    post '/users/invitation/batch' => 'user_invitations#create_batch'
  end

  # require authentication before allowing user to submit things
  authenticate :user do
    # user reputation_links
    match '/users/:id/rep', to: 'users#endorse', via: [:post]
    match '/users/:id/rep', to: 'users#unendorse', via: [:delete]

    # user moderation actions
    match '/users/:id/add_rep', to: 'users#add_rep', via: [:post]
    match '/users/:id/subtract_rep', to: 'users#subtract_rep', via: [:post]
    match '/users/:id/change_role', to: 'users#change_role', via: [:post]

    # user settings
    match '/settings/:id', to: 'user_settings#show', via: [:get]
    match '/settings/:id', to: 'user_settings#update', via: [:patch, :put]
    match '/settings/avatar', to: 'user_settings#avatar', via: [:post]
    match '/settings/link_account', to: 'user_settings#link_account', via: [:post]

    # notifications
    match '/notifications/recent', to: 'notifications#recent', via: [:get]
    match '/notifications/read', to: 'notifications#read', via: [:post]
    match '/notifications', to: 'notifications#index', via: [:post, :get]

    # events
    match '/events', to: 'events#index', via: [:post, :get]

    # scraping
    match '/nexus_infos/:id', to: 'nexus_infos#show', via: [:get]
    match '/lover_infos/:id', to: 'lover_infos#show', via: [:get]
    match '/workshop_infos/:id', to: 'workshop_infos#show', via: [:get]

    # tags
    match '/tags/:id/hide', to: 'tags#hide', via: [:post]
    match '/tags/:id', to: 'tags#update', via: [:patch, :put]
    match '/mods/:id/tags', to: 'mods#update_tags', via: [:patch, :put]
    match '/mod_lists/:id/tags', to: 'mod_lists#update_tags', via: [:patch, :put]

    # mods
    match '/mods/:id/hide', to: 'mods#hide', via: [:post]
    match '/mods/:id/approve', to: 'mods#approve', via: [:post]
    match '/mods/:id/image', to: 'mods#image', via: [:post]
    resources :mods, only: [:new, :create, :edit, :update]

    # curator requests
    match '/curator_requests/index', to: 'curator_requests#index', via: [:get, :post]
    resources :curator_requests, only: [:create, :update]

    # reviews
    match '/reviews/:id/approve', to: 'reviews#approve', via: [:post]
    match '/reviews/:id/hide', to: 'reviews#hide', via: [:post]
    resources :reviews, only: [:create, :update]

    # compatibility notes
    match '/compatibility_notes/:id/approve', to: 'compatibility_notes#approve', via: [:post]
    match '/compatibility_notes/:id/hide', to: 'compatibility_notes#hide', via: [:post]
    resources :compatibility_notes, only: [:create, :update]

    # install order notes
    match '/install_order_notes/:id/hide', to: 'install_order_notes#hide', via: [:post]
    resources :install_order_notes, only: [:create, :update]

    # load order notes
    match '/load_order_notes/:id/hide', to: 'load_order_notes#hide', via: [:post]
    match '/install_order_notes/:id/approve', to: 'install_order_notes#approve', via: [:post]
    resources :load_order_notes, only: [:create, :update]

    # corrections
    match '/corrections/:id/hide', to: 'corrections#hide', via: [:post]
    match '/load_order_notes/:id/approve', to: 'load_order_notes#approve', via: [:post]
    match '/corrections/:id/agreement', to: 'corrections#agreement', via: [:post]
    resources :corrections, only: [:create, :update]

    # comments
    match '/comments/:id/hide', to: 'comments#hide', via: [:post]
    resources :comments, only: [:create, :update]

    # helpful marks
    match '/reviews/:id/helpful', to: 'reviews#helpful', via: [:post]
    match '/compatibility_notes/:id/helpful', to: 'compatibility_notes#helpful', via: [:post]
    match '/install_order_notes/:id/helpful', to: 'install_order_notes#helpful', via: [:post]
    match '/load_order_notes/:id/helpful', to: 'load_order_notes#helpful', via: [:post]

    # mod lists
    match '/mod_lists/active', to: 'mod_lists#set_active', via: [:post]
    match '/mod_lists/:id/import', to: 'mod_lists#import', via: [:post]
    match '/mod_lists/:id/hide', to: 'mod_lists#hide', via: [:post]
    match '/mod_lists/:id/clone', to: 'mod_lists#clone', via: [:post]
    match '/mod_lists/:id/add', to: 'mod_lists#add', via: [:post]
    match '/mod_list_groups', to: 'mod_list_groups#create', via: [:post]
    match '/mod_list_mods', to: 'mod_list_mods#create', via: [:post]
    match '/mod_list_mods', to: 'mod_list_mods#destroy', via: [:delete]
    match '/mod_list_plugins', to: 'mod_list_plugins#create', via: [:post]
    match '/mod_list_config_files', to: 'mod_list_config_files#create', via: [:post]
    match '/mod_list_custom_mods', to: 'mod_list_custom_mods#create', via: [:post]
    match '/mod_list_custom_plugins', to: 'mod_list_custom_plugins#create', via: [:post]
    match '/mod_list_custom_config_files', to: 'mod_list_custom_config_files#create', via: [:post]
    resources :mod_lists, only: [:create, :update]

    # mod list exporting
    match 'mod_lists/:id/export_modlist', to: 'mod_lists#export_modlist', via: [:get]
    match 'mod_lists/:id/export_plugins', to: 'mod_lists#export_plugins', via: [:get]
    match 'mod_lists/:id/export_links', to: 'mod_lists#export_links', via: [:get]

    # mod and mod list stars
    match '/mod_lists/:id/star', to: 'mod_lists#create_star', via: [:post]
    match '/mod_lists/:id/star', to: 'mod_lists#destroy_star', via: [:delete]
    match '/mods/:id/star', to: 'mods#create_star', via: [:post]
    match '/mods/:id/star', to: 'mods#destroy_star', via: [:delete]

    # help pages
    match '/help/:id/destroy', to: 'help_pages#destroy', via: [:get]
    resources :help_pages, path: 'help', only: [:new, :create, :edit, :update]

    #articles
    match '/articles/:id/image', to: 'articles#image', via: [:post]
    resources :articles, only: [:new, :create, :edit, :update, :destroy]

    # reports
    match '/reports/index', to: 'reports#index', via: [:get, :post]
    match '/reports', to: 'reports#create', via: [:post]
    match '/reports/:id/resolve', to: 'reports#resolve', via: [:post]
  end

  # users
  match '/current_user', to: 'users#current', via: [:get]
  match '/users/index', to: 'users#index', via: [:get, :post]
  match '/users/search', to: 'users#search', via: [:post]
  match '/users/:id', to: 'users#show', via: [:get]

  # user associations
  match '/users/:id/comments', to: 'users#comments', via: [:get, :post]
  match '/users/:id/mods', to: 'users#mods', via: [:get]
  match '/users/:id/mod_lists', to: 'users#mod_lists', via: [:get]

  # tags
  match '/all_tags', to: 'tags#all', via: [:get]
  match '/tags', to: 'tags#index', via: [:post]

  # mods
  match '/mods/index', to: 'mods#index', via: [:get, :post]
  match '/mods/search', to: 'mods#search', via: [:post]
  resources :mods, only: [:show]

  # mod options
  match '/mod_options/search', to: 'mod_options#search', via: [:post]

  # plugins
  match '/plugins', to: 'plugins#index', via: [:get, :post]
  match '/plugins/search', to: 'plugins#search', via: [:post]
  match '/plugins/:id', to: 'plugins#show', via: [:get]

  # content associated with mods
  match '/mods/:id/corrections', to: 'mods#corrections', via: [:get, :post]
  match '/mods/:id/reviews', to: 'mods#reviews', via: [:get, :post]
  match '/mods/:id/compatibility_notes', to: 'mods#compatibility_notes', via: [:get, :post]
  match '/mods/:id/install_order_notes', to: 'mods#install_order_notes', via: [:get, :post]
  match '/mods/:id/load_order_notes', to: 'mods#load_order_notes', via: [:get, :post]
  match '/mods/:id/analysis', to: 'mods#analysis', via: [:get, :post]

  # reviews
  match '/reviews/index', to: 'reviews#index', via: [:get, :post]
  resources :reviews, only: [:show]

  # compatibility notes
  match '/compatibility_notes/index', to: 'compatibility_notes#index', via: [:get, :post]
  match '/compatibility_notes/:id/corrections', to: 'compatibility_notes#corrections', via: [:get]
  match '/compatibility_notes/:id/history', to: 'compatibility_notes#history', via: [:get]
  resources :compatibility_notes, only: [:show]

  # install order notes
  match '/install_order_notes/index', to: 'install_order_notes#index', via: [:get, :post]
  match '/install_order_notes/:id/corrections', to: 'install_order_notes#corrections', via: [:get]
  match '/install_order_notes/:id/history', to: 'install_order_notes#history', via: [:get]
  resources :install_order_notes, only: [:show]

  # load order notes
  match '/load_order_notes/index', to: 'load_order_notes#index', via: [:get, :post]
  match '/load_order_notes/:id/corrections', to: 'load_order_notes#corrections', via: [:get]
  match '/load_order_notes/:id/history', to: 'load_order_notes#history', via: [:get]
  resources :load_order_notes, only: [:show]

  # corrections
  match '/corrections/index', to: 'corrections#index', via: [:get, :post]
  match '/corrections/:id/comments', to: 'corrections#comments', via: [:get, :post]
  resources :corrections, only: [:show]

  # comments
  match '/comments/index', to: 'comments#index', via: [:get, :post]
  resources :comments, only: [:show]

  # mod lists
  match '/mod_lists/active', to: 'mod_lists#active', via: [:get]
  match '/mod_lists/index', to: 'mod_lists#index', via: [:get, :post]
  match '/mod_lists/:id/mods', to: 'mod_lists#mods', via: [:get, :post]
  match '/mod_lists/:id/tools', to: 'mod_lists#tools', via: [:get, :post]
  match '/mod_lists/:id/plugins', to: 'mod_lists#plugins', via: [:get, :post]
  match '/mod_lists/:id/config', to: 'mod_lists#config_files', via: [:get, :post]
  match '/mod_lists/:id/analysis', to: 'mod_lists#analysis', via: [:get, :post]
  match '/mod_lists/:id/comments', to: 'mod_lists#comments', via: [:get, :post]
  resources :mod_lists, only: [:show]

  # help pages
  match '/help/category/:category', to: 'help_pages#category', via: [:get]
  match '/help/game/:game', to: 'help_pages#game', via: [:get]
  match '/help/:id/comments', to: 'help_pages#comments', via: [:get, :post]
  match '/help/search', to:  'help_pages#search', via: [:get]
  resources :help_pages, path: 'help', except: [:new, :create, :edit, :update, :destroy]
  match '/help/*path', to: 'help_pages#record_not_found', via: :all

  # static data
  resources :categories, only: [:index]
  resources :category_priorities, only: [:index]
  resources :games, only: [:index]
  resources :quotes, only: [:index]
  resources :record_groups, only: [:index]
  resources :review_sections, only: [:index]
  resources :user_titles, only: [:index]

  # home page
  match '/skyrim', to: 'home#skyrim', via: [:get]
  match '/fallout4', to: 'home#fallout4', via: [:get]
  match '/home', to: 'home#index', via: [:get]

  #articles
  match '/articles/:id/comments', to: 'articles#comments', via: [:get, :post]
  match '/articles/index', to: 'articles#index', via: [:get, :post]
  resources :articles, only: [:show]

  # welcome page
  resources :welcome, only: [:index]

  # legal pages
  match '/legal', to: 'legal_pages#index', via: [:get]
  match '/legal/tos', to: 'legal_pages#tos', via: [:get]
  match '/legal/privacy', to: 'legal_pages#privacy', via: [:get]
  match '/legal/copyright', to: 'legal_pages#copyright', via: [:get]

  # contact us and subscribe
  match '/contacts', to: 'contacts#new', via: [:get]
  resources :contacts, only: [:new, :create]

  # You can have the root of your site routed with "root"
  root 'welcome#index'
end

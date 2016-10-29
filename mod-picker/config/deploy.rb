Airbrussh.configure do |config|
  config.command_output = false
end

# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'mod-picker'
set :repo_url, 'git@github.com/matortheeternal/mod-picker.git'
set :repo_tree, 'mod-picker'

set :deploy_to, '/var/www/mod-picker'

set :passenger_restart_with_touch, true

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w( config/database.yml config/scheduler.yml config/secrets.yml )

# Default value for linked_dirs is []
# TODO: Correct the uploads folder path and remove unnecessary paths
set :linked_dirs, %w( log tmp/pids tmp/cache tmp/sessions tmp/sockets vendor/bundle public/system public/uploads )

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rvm_type, :user
set :rvm_roles, [:app]

SSHKit.config.umask = "0002"

set :ssh_options, {
  forward_agent: true
}


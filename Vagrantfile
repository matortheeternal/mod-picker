# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# Shamelessly ripped from Active Support core_ext. Need a better solution. Later.
class Hash
  def deep_merge(other_hash, &block)
    dup.deep_merge!(other_hash, &block)
  end

  def deep_merge!(other_hash, &block)
    other_hash.each_pair do |current_key, other_value|
      this_value = self[current_key]

      self[current_key] = if this_value.is_a?(Hash) && other_value.is_a?(Hash)
        this_value.deep_merge(other_value, &block)
      else
        if block_given? && key?(current_key)
          block.call(current_key, this_value, other_value)
        else
          other_value
        end
      end
    end

    self
  end
end

settings = YAML.load_file 'vagrant.yml'

REQUIRED_PLUGINS = %w( vagrant-vbguest vagrant-berkshelf vagrant-omnibus vagrant-triggers)
PASSWORD_ERROR_MESSAGE = "You need to set your mariadb password in vagrant.yml to something other than 'password'"

def missing_plugins
  @missing_plugins ||= REQUIRED_PLUGINS.reject { |plugin| Vagrant.has_plugin? plugin }
end

def missing_multiple_plugins?
  missing_plugins.size > 1
end

if missing_plugins.any?
  STDERR << "The following plugin#{'s' if missing_multiple_plugins?} are required: #{missing_plugins.join(" ")}\n"
  STDERR << "Install #{missing_multiple_plugins? ? 'them' : 'it'} with this command: 'vagrant plugin install #{missing_plugins.join(" ")}'\n"
end

fail 'Required Vagrant plugins not installed. Please install before continuing' if missing_plugins.any?

fail PASSWORD_ERROR_MESSAGE if settings['mariadb']['password'] == 'password'

project_name = settings['project']['name']
mariadb_username = settings['mariadb']['username']
mariadb_password = settings['mariadb']['password']
forwarded_ports = settings['forwarded_ports'] || { :"3000" => 3000 }
vagrant_cpu_count = settings.fetch('vm', {}).fetch('cpu_count', 2)
vagrant_memory_size = settings.fetch('vm', {}).fetch('memory_size', '4096').to_s
vbguest_iso_path = settings.fetch('vbguest', {}).fetch('iso_path', nil)

chef_json = JSON.parse(File.read('vagrant.json'))

Vagrant.configure(2) do |config|
  # Prevent problematic caching of synced folders
  def remove_synced_folders_file(*_args)
    `rm .vagrant/machines/default/virtualbox/synced_folders`
  end

  config.trigger.before [:reload], stdout: true, &method(:remove_synced_folders_file)
  config.trigger.after [:halt], stdout: true, &method(:remove_synced_folders_file)

  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  config.vm.box = 'ubuntu/xenial64'

  config.vm.synced_folder '.', "/home/ubuntu/#{project_name}"

  config.vbguest.auto_update = true
  config.vbguest.iso_path = vbguest_iso_path if vbguest_iso_path

  config.vm.provider :virtualbox do |vb|
    vb.name = project_name
    vb.memory = vagrant_memory_size
    vb.cpus = vagrant_cpu_count
  end

  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true

  forwarded_ports.each do |guest_port, host_port|
    config.vm.network :forwarded_port, guest_ip: '0.0.0.0', guest: guest_port, host: host_port, autocorrect: true
  end

  config.ssh.keys_only = true
  config.ssh.insert_key = true
  config.ssh.forward_agent = true

  config.omnibus.chef_version = '12.12.15'
  config.berkshelf.enabled = false

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['cookbooks', 'site-cookbooks', 'berks-cookbooks']

    chef.add_recipe 'apt_config'
    chef.add_recipe 'apt'

    chef.json = {
      apt: {
        compiletime: true
      },
      "run_list" => %w[
        recipe[apt_config],
        recipe[apt]
      ]
    }
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = ['cookbooks', 'site-cookbooks', 'berks-cookbooks']

    chef.add_recipe 'apt'
    chef.add_recipe 'build-essential'
    chef.add_recipe 'nodejs'
    chef.add_recipe 'ruby_build'
    chef.add_recipe 'ruby_rbenv::user'
    chef.add_recipe 'mariadb::server'
    chef.add_recipe 'mariadb::client'

    chef.json = chef_json
  end

  user_creation_mysql = <<-SCRIPT_SQL
    CREATE USER IF NOT EXISTS '#{mariadb_username}'@'localhost' IDENTIFIED BY '#{mariadb_password}';
    CREATE USER IF NOT EXISTS '#{mariadb_username}'@'%' IDENTIFIED BY '#{mariadb_password}';

    GRANT ALL PRIVILEGES ON \\`#{mariadb_username}\\` . * TO '#{mariadb_username}'@'localhost';
    GRANT ALL PRIVILEGES ON \\`#{mariadb_username}\\` . * TO '#{mariadb_username}'@'%';
    GRANT ALL PRIVILEGES ON \\`#{mariadb_username}_%\\` . * TO '#{mariadb_username}'@'localhost';
    GRANT ALL PRIVILEGES ON \\`#{mariadb_username}_%\\` . * TO '#{mariadb_username}'@'%';
  SCRIPT_SQL

  setup_mariadb_script = <<-SCRIPT
    #!/bin/bash

    if [ ! -f ~/.setup_mariadb_script ]
    then
      echo '===== Creating MariaDB user ====='
      echo "#{user_creation_mysql}"
      mysql --password=this_is_a_really_terrible_password -e "#{user_creation_mysql}"
      touch ~/.setup_mariadb_script
    fi
  SCRIPT

  change_ssh_directory_script = <<-SCRIPT
    if [ $(pwd) != "~/#{project_name}/#{project_name}" ]; then
      echo "cd ~/#{project_name}/#{project_name}" >> ~/.profile
    fi
  SCRIPT

  initialize_rails_app = <<-SCRIPT
    echo 'Bundling...'
    cd /home/ubuntu/#{project_name}/mod-picker
    bundle
    rbenv rehash
    echo 'Creating DB'
    rake db:create
    echo 'Loading Schema'
    rake db:schema:load
    echo 'Seeding DB'
    rake db:seed
  SCRIPT

  unprivileged_initialize_script = <<-SCRIPT
    #!/bin/bash

    if [ ! -f ~/.unprivileged_initialized ]
    then
      #{initialize_rails_app}
      touch ~/.unprivileged_initialized
    fi
  SCRIPT

  config.vm.provision :shell, name: 'Setup MariaDB', inline: setup_mariadb_script
  config.vm.provision :shell, privileged: false, name: 'Unprivileged Initialization', inline: unprivileged_initialize_script
  config.vm.provision :shell, name: 'Setup Home Directory', privileged: false, inline: change_ssh_directory_script
end

#
# Cookbook Name:: ruby_rbenv
# Library:: Chef::RubyBuild::RecipeHelpers
#
# Author:: Fletcher Nichol <fnichol@nichol.ca>
#
# Copyright 2011-2016, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  module Rbenv
    module RecipeHelpers
      def build_upgrade_strategy(strategy)
        if strategy.nil? || strategy == false
          'none'
        else
          strategy
        end
      end

      def mac_with_no_homebrew
        node['platform'] == 'mac_os_x' &&
          Chef::Platform.find_provider_for_node(node, :package) !=
            Chef::Provider::Package::Homebrew
      end

      def install_rbenv_pkg_prereqs
        return if mac_with_no_homebrew

        node['rbenv']['install_pkgs'].each { |pkg| package pkg }
      end

      def install_or_upgrade_rbenv(opts = {})
        git_deploy_rbenv opts
        initialize_rbenv opts
        add_rbenv_to_path
      end

      private

      def git_deploy_rbenv(opts)
        git_exec_action = if opts[:upgrade_strategy] == 'none'
                            :checkout
                          else
                            :sync
                          end

        git opts[:rbenv_prefix] do
          repository opts[:git_url]
          reference opts[:git_ref]
          user opts[:user] if opts[:user]
          group opts[:group] if opts[:group]
          action git_exec_action
        end

        directory "#{opts[:rbenv_prefix]}/plugins" do
          owner opts[:user].nil? ? 'root' : opts[:user]
          mode '0755'
        end

        Array(opts[:rbenv_plugins]).each do |plugin|
          revision = plugin['revision'].nil? ? 'master' : plugin['revision']
          plugin_path = "#{opts[:rbenv_prefix]}/plugins/#{plugin['name']}"

          git "Install rbenv plugin - #{plugin['name']}" do
            repository plugin['git_url']
            destination plugin_path
            reference revision
            user opts[:user] if opts[:user]
            group opts[:group] if opts[:group]
            action :sync
          end
          log "Installed rbenv plugin - #{plugin['name']}"
        end
      end

      def initialize_rbenv(opts)
        prefix = opts[:rbenv_prefix]

        init_env = if opts[:user]
                     { 'USER' => opts[:user], 'HOME' => opts[:home_dir] }
                   else
                     {}
                   end

        bash "Initialize rbenv (#{opts[:user] || 'system'})" do
          code %(PATH="#{prefix}/bin:$PATH" rbenv init -)
          environment({ 'RBENV_ROOT' => prefix }.merge(init_env))
          user opts[:user] if opts[:user]
          group opts[:group] if opts[:group]
        end

        log "rbenv-post-init-#{opts[:user] || 'system'}"
      end

      def add_rbenv_to_path
        ruby_block 'Add rbenv to PATH' do
          block do
            rbenv_root = node['rbenv']['root_path']
            ENV['PATH'] = "#{rbenv_root}/shims:#{rbenv_root}/bin:#{ENV['PATH']}"
          end
        end
      end
    end
  end
end

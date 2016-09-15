#
# Cookbook Name:: apt_config
# Recipe:: default
#
# Copyright 2016, John Epperson
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

package "software-properties-common" do
  action :install
end

apt_repository 'jaleco.com' do
  uri 'http://mirror.jaleco.com/mariadb/repo/10.1/ubuntu'
  components ['main']
  distribution 'xenial'
  arch 'amd64'
  key '0xF1656F24C74CD1D8'
  keyserver 'keyserver.ubuntu.com'
  action :add
  deb_src true
end

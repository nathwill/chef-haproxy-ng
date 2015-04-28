#
# Cookbook Name:: haproxy-ng
# Recipe:: install
#
# Copyright 2015 Nathan Williams
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

case node['haproxy']['install_method']
when 'package'
  package 'haproxy'
when 'ppa'
  apt_repository 'haproxy' do
    uri node['haproxy']['ppa']['uri']
    distribution node['lsb']['codename']
    components ['main']
    keyserver 'keyserver.ubuntu.com'
    key node['haproxy']['ppa']['key']
  end

  package 'haproxy'
when 'source'
  node.default['haproxy']['source']['archive_url'] = [
    node['haproxy']['source']['url'],
    node['haproxy']['source']['version'],
    'src',
    "haproxy-#{node['haproxy']['source']['release']}.tar.gz"
  ].join('/')

  src = node['haproxy']['source']

  src['dependencies'].each do |dep|
    package dep
  end

  download_path = Chef::Config['file_cache_path'] || '/tmp'
  pkg_path = "#{download_path}/haproxy-#{src['release']}.tar.gz"

  execute 'compile-haproxy' do
    cwd "#{download_path}/haproxy-#{src['release']}"
    command <<-EOC
      make #{src['make_args']} && \
      make install
    EOC
    action :nothing
  end

  execute 'extract-haproxy' do
    cwd download_path
    command <<-EOC
      tar xzf #{::File.basename(pkg_path)} -C #{download_path}
    EOC
    action :nothing
    notifies :run, 'execute[compile-haproxy]', :immediately
  end

  remote_file 'haproxy-src-archive' do
    path pkg_path
    source src['archive_url']
    notifies :run, 'execute[extract-haproxy]', :immediately
  end

  directory '/etc/haproxy'

  user 'haproxy' do
    home '/var/lib/haproxy'
    shell '/usr/sbin/nologin'
    system true
  end

  directory '/var/lib/haproxy' do
    owner 'haproxy'
    group 'haproxy'
  end

  cookbook_file '/etc/init/haproxy.conf' do
    source 'haproxy.conf'
    mode '0755'
    only_if do
      ::File.directory?('/etc/init')
    end
  end

  cookbook_file '/etc/systemd/system/haproxy.service' do
    source 'haproxy.service'
    only_if do
      ::File.directory?('/etc/systemd/system')
    end
  end
else
  Chef::Log.warn 'Unknown install_method for haproxy. Skipping install!'
end

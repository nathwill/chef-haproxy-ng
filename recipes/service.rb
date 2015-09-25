#
# Cookbook Name:: haproxy-ng
# Recipe:: service
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

cookbook_file '/etc/default/haproxy' do
  source 'haproxy.default.cfg'
  only_if { platform?('ubuntu') }
end

service 'haproxy' do
  if File.executable?('/sbin/initctl') &&
     node['haproxy']['install_method'] == 'source'
    provider Chef::Provider::Service::Upstart
  end
  action [:enable, :start]
  supports :status => :true, :restart => :true, :reload => :true
  subscribes :reload, 'haproxy_instance[haproxy]', :delayed
  subscribes :reload, 'cookbook_file[/etc/default/haproxy]', :delayed
end

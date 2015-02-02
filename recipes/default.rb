#
# Cookbook Name:: haproxy-ng
# Recipe:: default
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

include_recipe "#{cookbook_name}::install"

haproxy_defaults 'http' do
  mode 'http'
  config [
    'timeout connect 5000ms',
    'timeout client 50000ms',
    'timeout server 50000ms',
  ]
end

haproxy_frontend 'www' do
  bind '*:80'
  default_backend 'app'
end

app_members = search(:node, 'roles:app').map do |n|
  {
    :name => n.name,
    :address => n.ipaddress,
    :port => 80,
    :config => 'check inter 5000 rise 2 fall 5',
  }
end

haproxy_backend 'app' do
  servers app_members
  config [
    "option httpchk GET /health_check HTTP/1.1\r\nHost:\ my-app.com",
  ]
end

my_proxies = %w( http www app ).map do |p|
  Haproxy::Helpers.proxy(p, run_context)
end

haproxy_instance 'haproxy' do
  config [
    'daemon',
    'user haproxy',
    'group haproxy',
    'pidfile /var/run/haproxy.pid',
    'chroot /var/lib/haproxy',
  ]
  tuning [
    'maxconn 50000',
  ]
  proxies my_proxies
  notifies :reload, 'service[haproxy]', :delayed
end

service 'haproxy' do
  action [:enable, :start]
end

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

haproxy_defaults 'TCP' do
  mode 'tcp'
  config [
    'option srvtcpka',
    'option clitcpka'
  ]
end

haproxy_defaults 'HTTP' do
  mode 'http'
  config [
    'maxconn 50000',
    'timeout connect 5s',
    'timeout client 50s',
    'timeout server 50s'
  ]
end

redis_members = search(:node, 'role:redis').map do |s|
  {
    'name' => s.name,
    'address' => s.ipaddress,
    'port' => 6379,
    'config' => 'backup check inter 1000 rise 2 fall 5'
  }
end

haproxy_listen 'redis' do
  bind '0.0.0.0:6379'
  servers redis_members
  config [
    'tcp-check send PING\r\n',
    'tcp-check expect string +PONG',
    'tcp-check send info\ replication\r\n',
    'tcp-check expect string role:master',
    'tcp-check send QUIT\r\n',
    'tcp-check expect string +OK'
  ]
end

app_role = node['haproxy']['app_role']

if Chef::Config[:solo]
  app_members = { 'name' => 'app', 'address' => '127.0.0.1', 'port' => 80 }
else
  app_members = search(:node, "role:#{app_role}").map do |n|
    {
      'name' => n.name,
      'address' => n.ipaddress,
      'port' => 80,
      'config' => 'check inter 5000 rise 2 fall 5'
    }
  end
end

haproxy_backend 'app' do
  servers app_members
  config [
    'option httpchk GET /health_check HTTP/1.1\r\nHost:\ localhost'
  ]
end

haproxy_frontend 'www' do
  bind '*:80'
  default_backend 'app'
end

my_proxies = %w( TCP redis HTTP www app ).map do |p|
  Haproxy::Helpers.proxy(p, run_context)
end

haproxy_instance 'haproxy' do
  config [
    'daemon',
    'user haproxy',
    'group haproxy',
    'pidfile /var/run/haproxy.pid'
  ]
  tuning [
    'maxconn 50000'
  ]
  proxies my_proxies
  notifies :run, 'execute[validate-haproxy_instance-haproxy]', :immediately
end

execute 'validate-haproxy_instance-haproxy' do
  command 'haproxy -c -f /etc/haproxy/haproxy.cfg'
  notifies :reload, 'service[haproxy]', :delayed
  action :nothing
end

include_recipe "#{cookbook_name}::service"

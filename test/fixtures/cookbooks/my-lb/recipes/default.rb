# Exercise all resources and their attributes for testing,
# even though this generates a pretty silly configuration.

lb_peers = search(:node, 'role:lb').map do |lb|
  "peer #{lb.name} #{lb['ipaddress']}:1024"
end

lb_peers.unshift "peer #{node.name}.vagrantup.com #{node['ipaddress']}:1024"

haproxy_peers 'lb' do
  config lb_peers
  not_if { platform?('ubuntu') && node['platform_version'] =~ /1(2|4).04/ }
end

haproxy_userlist 'L1' do
  config [
    'group G1 users tiger,scott',
    'group G2 users xdb,scott',
    'user tiger insecure-password password123',
    'user scott insecure-password pa55word123',
    'user xdb insecure-password hello',
  ]
end

mysql_members = search(:node, 'role:mysql').map do |s|
  {
    'name' => s.name,
    'address' => s.ipaddress,
    'port' => 3306,
    'config' => 'maxconn 500 check port 3306 inter 2s backup'
  }
end

haproxy_listen 'mysql' do
  mode 'tcp'
  acls [
    {
      'name' => 'inside',
      'criterion' => 'src 10.0.0.0/8'
    }
  ]
  description 'mysql pool'
  balance 'leastconn'
  source node['ipaddress']
  bind '0.0.0.0:3306'
  servers mysql_members
  config [
    'option mysql-check'
  ]
end

haproxy_defaults 'TCP' do
  mode 'tcp'
  balance 'leastconn'
  source node['ipaddress']
  config [
    'option clitcpka',
    'option srvtcpka',
    'timeout connect 5s',
    'timeout client 300s',
    'timeout server 300s'
  ]
end

if Chef::Config[:solo]
  app_members = { 'name' => 'app', 'address' => '127.0.0.1', 'port' => 80 }
else
  app_members = search(:node, "role:app").map do |n|
    {
      'name' => n.name,
      'address' => n.ipaddress,
      'port' => 80,
      'config' => 'check inter 5000 rise 2 fall 5'
    }
  end
end

haproxy_backend 'should_not_exist' do
  not_if { true }
end

haproxy_backend 'app' do
  mode 'http'
  acls [
    {
      'name' => 'inside',
      'criterion' => 'src 10.0.0.0/8'
    }
  ]
  description 'app pool'
  balance 'roundrobin'
  source node['ipaddress']
  servers app_members
  config [
    'option httpchk GET /health_check HTTP/1.1\r\nHost:\ localhost'
  ]
end

haproxy_frontend 'www' do
  mode 'http'
  acls [
    {
      'name' => 'inside',
      'criterion' => 'src 10.0.0.0/8'
    }
  ]
  description 'http frontend'
  bind '*:80'
  default_backend 'app'
  use_backends [
    {
      'backend' => 'app',
      'condition' => 'if inside'
    }
  ]
  config [
    'option clitcpka'
  ]
end

haproxy_defaults 'HTTP' do
  mode 'http'
  default_backend 'app'
  balance 'roundrobin'
  source node['ipaddress']
  config [
    'maxconn 2000',
    'timeout connect 5s',
    'timeout client 50s',
    'timeout server 50s'
  ]
end

include_recipe 'haproxy-ng'

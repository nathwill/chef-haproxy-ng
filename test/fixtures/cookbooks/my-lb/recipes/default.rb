# Exercise all resources and their attributes for testing,
# even though this generates a pretty silly configuration.

lb_peers = search(:node, 'role:lb').map do |lb|
  {
    'name' => lb.name,
    'address' => lb.ipaddress,
    'port' => 1024
  }
end

lb_peers << {
  'name' => node['machinename'],
  'address' => node.ipaddress,
  'port' => 1024
}

haproxy_peers 'lb' do
  peers lb_peers
  not_if { platform?('ubuntu') && node['platform_version'] =~ /1(2|4).04/ }
end

haproxy_userlist 'L1' do
  groups [
    { 'name' => 'G1', 'config' => 'users tiger,scott' },
    { 'name' => 'G2', 'config' => 'users xdb,scott' }
  ]
  users [
    { 'name' => 'tiger', 'config' => 'insecure-password password123' },
    { 'name' => 'scott', 'config' => 'insecure-password pa55word123' },
    { 'name' => 'xdb', 'config' => 'insecure-password hello' }
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

# Temporarily disable the validation so we can create a bogus resource.
# Reusing the actionable proxy test lets us confirm disabling compile-time
# validation works, without also screwing up the rendered configuration.	
haproxy_backend 'should_not_exist' do
  verify false
  config [
    'bind 127.0.0.1:8080' # bogus config
  ]
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

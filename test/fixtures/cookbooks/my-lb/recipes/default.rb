# Exercise all resources and their attributes for testing,
# even though this generates a pretty silly configuration.

redis_members = search(:node, 'role:redis').map do |s|
  {
    'name' => s.name,
    'address' => s.ipaddress,
    'port' => 6379,
    'config' => 'backup check inter 1000 rise 2 fall 5'
  }
end

haproxy_listen 'redis' do
  mode 'tcp'
  acls [
    {
      'name' => 'inside',
      'criterion' => 'src 10.0.0.0/8'
    }
  ]
  description 'redis pool'
  balance 'leastconn'
  source node['ipaddress']
  bind '0.0.0.0:6379'
  servers redis_members
  config [
    'option tcp-check',
    'tcp-check send PING\r\n',
    'tcp-check expect string +PONG',
    'tcp-check send info\ replication\r\n',
    'tcp-check expect string role:master',
    'tcp-check send QUIT\r\n',
    'tcp-check expect string +OK'
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
    'maxconn 50000',
    'timeout connect 5s',
    'timeout client 50s',
    'timeout server 50s'
  ]
end

include_recipe 'haproxy-ng'

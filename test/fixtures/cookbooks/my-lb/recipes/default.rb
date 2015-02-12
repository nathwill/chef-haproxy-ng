haproxy_defaults 'TCP' do
  mode 'tcp'
  config [
    'option clitcpka',
    'option srvtcpka',
    'timeout connect 5s',
    'timeout client 300s',
    'timeout server 300s'
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
    'option tcp-check',
    'tcp-check send PING\r\n',
    'tcp-check expect string +PONG',
    'tcp-check send info\ replication\r\n',
    'tcp-check expect string role:master',
    'tcp-check send QUIT\r\n',
    'tcp-check expect string +OK'
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

include_recipe 'haproxy-ng'

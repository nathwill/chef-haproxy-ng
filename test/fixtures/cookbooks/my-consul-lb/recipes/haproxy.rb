# Exercise all resources and their attributes for testing,
# even though this generates a pretty silly configuration.

haproxy_peers 'lb' do
  verify false
  config [
    '{{range service "haproxy-peers"}}',
    'peer {{.Node}} {{.Address}}:{{.Port}}',
    '{{end}}',
  ]
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

haproxy_listen 'mysql' do
  verify false
  mode 'tcp'
  acls [
    {
      'name' => 'inside',
      'criterion' => 'src 10.0.0.0/8'
    }
  ]
  description 'mysql pool'
  source node['ipaddress']
  bind '0.0.0.0:3306'
  config [
    'option mysql-check',
    '{{range service "mysql"}}',
    'server {{.Node}} {{.Address}}:{{.Port}}',
    '{{end}}',
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
  verify false
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
  config [
    'option httpchk GET /health_check HTTP/1.1\r\nHost:\ localhost',
    '{{range service "my-app"}}',
    'server {{.Node}} {{.Address}}:{{.Port}}',
    '{{end}}',
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

include_recipe "haproxy-ng::install"

my_proxies = node['haproxy']['proxies'].map do |p|
  Haproxy::Helpers.proxy(p, run_context)
end

haproxy_instance 'consul-template' do
  verify false
  config node['haproxy']['config']
  tuning node['haproxy']['tuning']
  proxies my_proxies
  notifies :reload, 'service[consul-template]', :delayed
end

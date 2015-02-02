#
# Spin up an instance
#

haproxy_proxy 'config_http' do
  type 'defaults'
  config [
    'mode http',
    'balance roundrobin',
    'timeout connect 5s',
    'timeout client 50s',
    'timeout server 50s',
  ]
end

haproxy_proxy 'http' do
  type 'frontend'
  config [
    'bind *:80',
    'acl methods_strict method HEAD GET PUT POST UPGRADE OPTIONS PATCH DELETE',
    'acl methods_avoid method TRACE CONNECT',
    'http-request deny if !methods_strict methods_avoid',
    'default_backend app',
  ]
end

haproxy_proxy 'app' do
  type 'backend'
  config [
    'option httpchk GET /health_check HTTP/1.1\r\nHost:\ my-app.com',
  ]
end

haproxy_proxy 'elasticsearch' do
  type 'backend'
  config [
    'bind *:9200',
  ]
end

haproxy_proxy 'config_tcp' do
  type 'defaults'
  config [
    'mode tcp',
    'option tcpka',
  ]
end

haproxy_proxy 'mysql' do
  type 'listen'
  config [
    'bind *:3306',
    'option mysql-check',
  ]
end

haproxy_proxy 'redis' do
  type 'listen'
  config [
    'bind *:6379',
    'option tcp-check',
    'tcp-check send PING\r\n',
    'tcp-check expect string +PONG',
    'tcp-check send info\ replication\r\n',
    'tcp-check expect string role:master',
    'tcp-check send QUIT\r\n',
    'tcp-check expect string +OK',
  ]
end

my_app_proxies = %w( http config_http app config_tcp mysql redis ).map do |n|
  Haproxy::Helpers.proxy(n, run_context)
end

haproxy_instance 'my-app' do
  config [
    'daemon',
  ]
  tuning [
    'maxconn 256',
  ]
  proxies my_app_proxies
  action :create
end

#
# Spin up an instance
#
haproxy_instance 'my-app' do
  config %w(

  )
  tuning %w(

  )
  peers({

  })
  proxies %w( http app mysql redis )
  action :create
end

haproxy_proxy 'http' do
  type 'frontend'
  config %w(

  )
end

haproxy_proxy 'app' do
  type 'backend'
  config [
    'mode http',
    'balance roundrobin',
  ]
end

haproxy_proxy 'mysql' do
  type 'listen'
  config [
    'mode tcp',
  ]
end

haproxy_proxy 'redis' do
  type 'listen'
  config [

  ]
end

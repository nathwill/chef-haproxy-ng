include_recipe 'consul'

consul_service_def 'haproxy-peers' do
  port 1024
  notifies :reload, 'service[consul]'
end

consul_service_def 'mysql' do
  port 3306
  notifies :reload, 'service[consul]'
end

consul_service_def 'my-app' do
  port 8080
  notifies :reload, 'service[consul]'
end

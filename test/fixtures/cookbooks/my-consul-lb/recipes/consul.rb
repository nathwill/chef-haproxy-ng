include_recipe 'consul'

consul_definition 'haproxy-peers' do
  type 'service'
  parameters port: 1024
  notifies :reload, 'consul_service[consul]'
end

consul_definition 'mysql' do
  type 'service'
  parameters port: 3306
  notifies :reload, 'consul_service[consul]'
end

consul_definition 'my-app' do
  type 'service'
  parameters port: 8080
  notifies :reload, 'consul_service[consul]'
end

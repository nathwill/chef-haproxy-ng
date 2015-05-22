include_recipe 'consul-template'

consul_template_config 'haproxy' do
  templates [{
    source: '/etc/haproxy/consul-template.cfg',
    destination: '/etc/haproxy/haproxy.cfg',
    command: 'systemctl restart haproxy.service'
  }]
  notifies :reload, 'service[consul-template]', :delayed
end

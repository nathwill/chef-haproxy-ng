
default['consul']['init_style'] = 'systemd'

default['consul_template']['init_style'] = 'systemd'
default['consul_template']['service_user'] = 'root'
default['consul_template']['service_group'] = 'root'

default['haproxy'].tap do |ha|
  ha['proxies'] = %w( lb L1 TCP mysql HTTP www app should_not_exist )
end

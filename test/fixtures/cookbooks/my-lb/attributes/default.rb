default['haproxy']['proxies'] = %w( lb L1 TCP mysql HTTP www app should_not_exist )
default['my-lb']['fe_config'] = ['option clitcpka']

# haproxy-ng cookbook  [![Build Status](https://travis-ci.org/nathwill/chef-haproxy-ng.svg?branch=master)](https://travis-ci.org/nathwill/chef-haproxy-ng)

A resource-driven cookbook for configuring [HAProxy](http://www.haproxy.org/).

Cookbook builds on 2 core resources:

- `haproxy_instance`: the "parent" resource, which maps to a complete configuration and (probably) a running haproxy daemon
- `haproxy_proxy`: the "core" proxy resource, which maps to a specific proxy

Additional resources `haproxy_peers`, `haproxy_userlist`, `haproxy_frontend`, 
`haproxy_backend`, `haproxy_defaults`, and `haproxy_listen` extend the `haproxy_proxy` 
resource with additional validation for common configuration keywords for their respective 
proxy types.

Suggested background reading:

- [The Fine Manual](http://cbonte.github.io/haproxy-dconv/configuration-1.5.html)
- This README, the modules in `libraries/haproxy*.rb`, and the individual resources/providers (`libraries/chef_haproxy*.rb`)
- the test target and example wrapper cookbook: 'test/fixtures/cookbooks/my-lb'
- the consul-template powered example wrapper cookbook:  'test/fixtures/cookbooks/my-consul-lb'

## Recipes

### haproxy-ng::default

Configures a default instance, 'haproxy_instance[haproxy]', and corresponding 
'haproxy' service via the `config`, `tuning`, and `proxies` cookbook attributes 
(which are mapped onto the corresponding resource attributes).

This recipe also provides a useful example of using the provided helper, 
`Haproxy::Helpers#proxy`, to map a list of proxies to their corresponding 
resources in the resource collection. 

See wrapper cookbook example at 'test/fixtures/cookbooks/my-lb'.

### haproxy-ng::install

Installs haproxy via the `node['haproxy']['install_method']` method.
Supports 'package', 'source', and 'ppa'.

### haproxy-ng::service

Configures a default-named ("haproxy") service resource.
 
Useful for typical installs running a single haproxy daemon under the default 
'haproxy' service name. Service providers, or those running multiple haproxy 
daemons on a single host will most likely want to configure a service instance 
per haproxy_instance.

## Attributes


|Attribute|Description|Default|
|---------|-----------|-------|
|install_method|One of: 'package', 'source', 'ppa'|`package`|
|proxies|Array of proxy names for the default haproxy_instance[haproxy]|[]|
|config|global config of resource haproxy_instance[haproxy]|See `attributes/default.rb`|
|tuning|global tuning of resource haproxy_instance[haproxy]|See `attributes/default.rb`|

And more! (see `attributes/*.rb`)

## Resources

### haproxy_instance

The "parent" resource. Maps 1-to-1 with a generated haproxy config file, 
and most likely to a running service.

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|config|global keywords for process mgmt|`['daemon']`|
|tuning|global keywords for performance|`['maxconn 256']`|
|debug|global keyword for debugging ('debug', 'quiet')|`nil`|
|proxies|array of proxies, see `default` recipe for example|[]|

### haproxy_proxy

The simplest proxy representation and base class for the other
proxy resources (peers, userlist, defaults, frontend, backend, listen).

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|type|String denoting proxy type. (defaults, frontend, backend, listen, peers, userlist)|nil|
|config|array of keywords, validated against specified type|[]|

### haproxy_peers

Maps to a peers block in haproxy configuration. Not actually a proxy,
but treating it like one is useful for code reusability. Don't judge me.

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|peers|array of hashes. each hash requires 'name', 'config' keys|[]|
|config|array of peers keywords. validated against whitelist|[]|


For example, this resource:

```ruby
haproxy_peers 'lb' do
  peers [
    {
      'name' => 'lb01',
      'address' => '12.4.56.78',
      'port' => 1_024
    },
    {
      'name' => 'lb02',
      'address' => '12.34.56.8',
      'port' => 1_024
    },
  ]
end
```

will render this configuration:

```text
peers lb
  peer lb01 12.4.56.78:1024
  peer lb02 12.34.56.8:1024
```

### haproxy_userlist

Maps to a userlist block in haproxy configuration. Also not actually a proxy, 
as such.

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|groups|array of hashes. hashes require 'name', 'config' keys|[]|
|users|array of hashes. hashes require 'name', 'config' keys|[]|
|config|array of userlist keywords, validated against whitelist|[]|

For example, this resource:

```ruby
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
```

will render this configuration:

```text
userlist L1
  group G1 users tiger,scott
  group G2 users xdb,scott
  user tiger insecure-password password123
  user scott insecure-password pa55word123
  user xdb insecure-password hello

```

### haproxy_defaults

Maps to a 'defaults' block in haproxy configuration. Convention
suggests that resource names be capitalized (e.g. haproxy_defaults[HTTP]).

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|mode|specifies listener mode (http, tcp, health)|nil|
|default_backend|argument to `default_backend` keyword|nil|
|balance|desired balancing algo (see docs for permitted values)|nil|
|source|argument to source keyword|nil|
|config|array of defaults keywords, validated against whitelist|[]|

For example, this resource:

```ruby
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
```

will render this configuration:

```text
defaults TCP
  balance leastconn
  mode tcp
  option clitcpka
  option srvtcpka
  timeout connect 5s
  timeout client 300s
  timeout server 300s
  source 10.0.2.15
```

### haproxy_frontend

Maps to a frontend block in the instance configuration, 
and typically to one or more listening ports or sockets.

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|mode|specifies listener mode (http, tcp, health)|nil|
|acls|array of hashes, each requiring 'name', 'criterion' keys|[]|
|description|string describing proxy|nil|
|bind|args to `bind` keyword|nil|
|default_backend|argument to `default_backend` keyword|nil|
|use_backends|array of hashes, each requiring 'backend', 'condition', keys|[]|
|config|array of frontend keywords, validated against whitelist|[]|
|config_tail|same as 'config' only appended after acls|[]|

For example, this resource:

```ruby
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
  config_tail [
    'http-request allow if inside'
  ]
end
```

will render this configuration:

```text
frontend www
  bind *:80
  mode http
  option clitcpka
  description http frontend
  acl inside src 10.0.0.0/8
  http-request allow if inside
  default_backend app
  use_backend app if inside
```

### haproxy_backend

Maps to a backend configuration block in haproxy configuration.

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|mode|specifies listener mode (http, tcp, health)|nil|
|acls|array of hashes, each requiring 'name', 'criterion' keys|[]|
|description|string describing proxy|nil|
|balance|desired balancing algo (see docs for permitted values)|nil|
|source|string specifying args to source keyword|nil|
|servers|array of hashes, each requiring 'name', 'address', 'port' keys. 'config' key optional|[]|
|config|array of backend keywords, validated against whitelist|[]|
|config_tail|same as 'config' only appended after acls|[]|

For example, this resource:

```ruby
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
  servers [
    {
      'name' => 'app01',
      'address' => '12.34.56.78',
      'port' => 80,
      'config' => 'check inter 5000 rise 2 fall 5'
    },
    {
      'name' => 'app02',
      'address' => '12.4.56.78',
      'port' => 80,
      'config' => 'check inter 5000 rise 2 fall 5'
    },
  ]
  config [
    'option httpchk GET /health_check HTTP/1.1\r\nHost:\ localhost'
  ]
  config_tail [
    'http-request allow if inside'
  ]
end
```

will render this configuration:

```text
backend app
  balance roundrobin
  mode http
  option httpchk GET /health_check HTTP/1.1\r\nHost:\ localhost
  description app pool
  acl inside src 10.0.0.0/8
  http-request allow if inside
  source 10.0.2.15
  server app01 12.34.56.78:80 check inter 5000 rise 2 fall 5
  server app02 22.4.56.78:80 check inter 5000 rise 2 fall 5
```

### haproxy_listen

Maps to a listen configuration block, combines frontend and backend config
blocks into a single proxy. Less flexible, but more concise. Typically used
for tcp-mode proxies with a 1:1 frontend:backend mapping.

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|mode|specifies listener mode (http, tcp, health)|nil|
|acls|array of hashes, each requiring 'name', 'criterion' keys|[]|
|description|string describing proxy|nil|
|balance|desired balancing algo (see docs for permitted values)|nil|
|source|string specifying args to source keyword|nil|
|servers|array of hashes, each requiring 'name', 'address', 'port' keys. 'config' key optional|[]|
|bind|args to `bind` keyword|nil|
|default_backend|argument to `default_backend` keyword|nil|
|use_backends|array of hashes, each requiring 'backend', 'condition', keys|[]|
|config|array of listen keywords, validated against whitelist|[]|
|config_tail|same as 'config' only appended after acls|[]|

For example, this resource:

```ruby
haproxy_listen 'mysql' do
  mode 'tcp'
  acls [
    {
      'name' => 'inside',
      'criterion' => 'src 10.0.0.0/8'
    }
  ]
  description 'mysql pool'
  balance 'leastconn'
  source node['ipaddress']
  bind '0.0.0.0:3306'
  servers [
    {
      'name' => 'mysql01',
      'address' => '12.34.56.89',
      'port' => 3_306,
      'config' => 'maxconn 500 check port 3306 inter 2s backup'
    },
    {
      'name' => 'mysql02',
      'address' => '12.34.56.90',
      'port' => 3_306,
      'config' => 'maxconn 500 check port 3306 inter 2s backup'
    },
  ]
  config [
    'option mysql-check'
  ]
  config_tail [
    'http-request allow if inside'
  ]
end
```

will generate this configuration:

```text
listen mysql
  bind 0.0.0.0:3306
  balance leastconn
  mode tcp
  option mysql-check
  description mysql pool
  acl inside src 10.0.0.0/8
  http-request allow if inside
  source 10.0.2.15
  server mysql01 12.34.56.89:3306 maxconn 500 check port 3306 inter 2s backup
  server mysql02 12.34.56.90:3306 maxconn 500 check port 3306 inter 2s backup
```

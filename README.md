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
- This README, the modules in `libraries/00_helpers.rb`, and the individual resources/providers
- the test target and example wrapper cookbook: 'test/fixtures/cookbooks/my-lb'
- the consul-template powered example wrapper cookbook:  'test/fixtures/cookbooks/my-consul-lb'

## Recipes

### haproxy-ng::default

Configures a default instance, 'haproxy_instance[haproxy]', and corresponding 
'haproxy' service via the `config`, `tuning`, and `proxies` cookbook attributes 
(which are mapped onto the corresponding resource attributes).

This recipe also provides a useful example of using the provided helper, 
`Haproxy::Helpers#proxy`, to map a list of proxies to their corresponding 
resources in the resource collection. It also illustrates the recommended 
pattern of proxying service reloads through a validating execute resource. 

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

### haproxy_userlist

Maps to a userlist block in haproxy configuration. Also not actually a proxy, 
as such.

|Attribute|Description|Default|
|---------|-----------|-------|
|verify|whether to perform resource whitelist validation|true|
|groups|array of hashes. hashes require 'name', 'config' keys|[]|
|users|array of hashes. hashes require 'name', 'config' keys|[]|
|config|array of userlist keywords, validated against whitelist|[]|

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


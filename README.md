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
- the test target and example wrapper cookbook 'test/fixtures/cookbooks/my-lb'

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

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>install_method</td>
      <td>
        One of: 'package', 'source', 'ppa'
      </td>
      <td><code>package</code></td>
    </tr>
    <tr>
      <td>proxies</td>
      <td>
        Array of proxy names for the default haproxy_instance[haproxy].
        Useful when used in conjunction with a wrapper cookbook that
        includes the default recipe.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of global configuration keywords passed to the `config` attribute
        of the haproxy_instance[haproxy] resource in the default recipe.
      </td>
      <td><code>See `attributes/default.rb`</code></td>
    </tr>
    <tr>
      <td>tuning</td>
      <td>
        Array of global configuration keywords passed to the `tuning` attribute
        of the haproxy_instance[haproxy] resource in the default recipe.
      </td>
      <td><code>See `attributes/default.rb`</code></td>
    </tr>
  </tbody>
</table>

## Resources

### haproxy_instance

The "parent" resource. Maps 1-to-1 with a generated haproxy config file, 
and most likely to a running service.

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>config</td>
      <td>
        Array of global keywords relevant to process management.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>['daemon','user haproxy', 'group haproxy', 'pidfile /var/run/haproxy.pid']</code></td>
    </tr>
    <tr>
      <td>tuning</td>
      <td>
        Array of global keywords relevant to performance tuning.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>['maxconn 50000']</code></td>
    </tr>
    <tr>
      <td>debug</td>
      <td>
        Global keyword string relevant to debugging (either 'debug', or 'quiet').
      </td>
      <td><code>app</code></td>
    </tr>
    <tr>
      <td>proxies</td>
      <td>
        Array of Chef::Resource::HaproxyProxy instances
        (`haproxy_{peers,userlist,defaults,frontend,backend,listen}` included).
        See the `default` recipe for an example of using the provided
        `Haproxy::Helpers#proxy` method to generate this list from the
        resource_collection.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_proxy

The simplest proxy representation and base class for the other
proxy resources (peers, userlist, defaults, frontend, backend, listen).

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>type</td>
      <td>
        String representing the proxy type. One of: 
        defaults, frontend, backend, listen, peers, userlist.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against specified proxy type.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_peers

Maps to a peers block in haproxy configuration. Not actually a proxy,
but treating it like one is useful for code reusability. Don't judge me.

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>peers</td>
      <td>
        Array of Hashes. Hashes require keys 'name', 'config'.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of peers keywords, validated against valid peers keywords.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_userlist

Maps to a userlist block in haproxy configuration. Also not actually a proxy, 
as such.

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>groups</td>
      <td>
        Array of Hashes. Hashes require keys 'name', 'config.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>users</td>
      <td>
        Array of Hashes. Hashes require keys 'name', 'config'.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of userlist keywords, validated against valid userlist keywords.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>


### haproxy_defaults

Maps to a 'defaults' block in haproxy configuration. Convention
suggests that resource names be capitalized (e.g. haproxy_defaults[HTTP]).

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>mode</td>
      <td>
        String specifying listener mode. One of: http, tcp, health.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>default_backend</td>
      <td>
        String specifying argument to `default_backend` keyword.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>balance</td>
      <td>
        String specifying the desired load-balancing algorithm.
        See `BALANCE_ALGORITHMS` in libraries/00_helpers.rb or haproxy
        manual for permissible `balance` keyword arguments.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>source</td>
      <td>
        `String` specifying arguments to the 'source' keyword.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against 'defaults' proxy type.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_frontend

Maps to a frontend block in the instance configuration, 
and typically to one or more listening ports or sockets.

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>mode</td>
      <td>
        String specifying listener mode. One of: http, tcp, health.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>acls</td>
      <td>
        Array of hashes. Each hash must contain keys `name`, and `criterion`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>description</td>
      <td>
        A `String` describing the related proxy.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>bind</td>
      <td>
        `String` or `Array` of strings containing arguments to `bind` keyword.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>default_backend</td>
      <td>
        String specifying argument to `default_backend` keyword.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>use_backends</td>
      <td>
        Array of Hashes mapping to a list of `use_backend` directives.
        Each hash is verified to have keys `backend` and `condition`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against 'frontend' proxy type.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_backend

Maps to a backend configuration block in haproxy configuration.

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>mode</td>
      <td>
        String specifying proxy mode. One of: http, tcp, health.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>acls</td>
      <td>
        Array of hashes. Each hash must contain keys `name`, and `criterion`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>description</td>
      <td>
        A `String` describing the related proxy.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>balance</td>
      <td>
        String specifying the desired load-balancing algorithm.
        See `BALANCE_ALGORITHMS` in libraries/00_helpers.rb or haproxy
        manual for permissible `balance` keyword arguments.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>source</td>
      <td>
        `String` specifying arguments to the 'source' keyword.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>servers</td>
      <td>
        Array of `Hashes`. Each `Hash` must contain keys `name`, `address`, `port`,
        and optionally `config`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against 'backend' proxy type.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_listen

Maps to a listen configuration block, combines frontend and backend config
blocks into a single proxy. Less flexible, but more concise. Typically used
for tcp-mode proxies with a 1:1 frontend:backend mapping.

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Default Value</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>mode</td>
      <td>
        String specifying proxy mode. One of: http, tcp, health.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>acls</td>
      <td>
        Array of hashes. Each hash must contain keys `name`, and `criterion`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>description</td>
      <td>
        A `String` describing the related proxy.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>balance</td>
      <td>
        String specifying the desired load-balancing algorithm.
        See `BALANCE_ALGORITHMS` in libraries/00_helpers.rb or haproxy
        manual for permissible `balance` keyword arguments.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>source</td>
      <td>
        `String` specifying arguments to the 'source' keyword.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>servers</td>
      <td>
        Array of `Hashes`. Each `Hash` must contain keys `name`, `address`, `port`,
        and optionally `config`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>bind</td>
      <td>
        `String` or `Array` of strings containing arguments to `bind` keyword.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>default_backend</td>
      <td>
        String specifying argument to `default_backend` keyword.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>use_backends</td>
      <td>
        Array of `Hash`es mapping to a list of `use_backend` directives.
        Each hash is verified to have keys `backend` and `condition`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against 'backend' proxy type.
        See `libraries/00_helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

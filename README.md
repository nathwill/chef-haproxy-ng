# haproxy-ng cookbook  [![Build Status](https://travis-ci.org/nathwill/chef-haproxy-ng.svg?branch=master)](https://travis-ci.org/nathwill/chef-haproxy-ng)

A resource-driven cookbook for configuring [HAProxy](http://www.haproxy.org/).

Cookbook builds on 2 core resources:

- `haproxy_instance`: the "parent" resource, which maps to a complete configuration and a running haproxy daemon.
- `haproxy_proxy`: the "core" proxy resource, which maps to a specific proxy

Additional resources `haproxy_frontend`, `haproxy_backend`, `haproxy_defaults`, 
and `haproxy_listen` extend the `haproxy_proxy` resource with additional validation 
for common configuration keywords for their respective proxy type.

Suggested background reading:

- This README, the modules in `libraries/helper.rb`, and the individual HWRPs
- [Manual](http://cbonte.github.io/haproxy-dconv/configuration-1.5.html)

_NOTE_: This cookbook is currently a beta quality release.

While it is believed to provide useful functionality, it has not been thoroughly
tested 'in the field'.

## Recipes

### haproxy-ng::default

Most users will not find this useful, it is primarily intended as a simple 
example of the resources, and a useful testing target.

Of particular use are the node-search -> backend server conversion, the 
example use of the `Haproxy::Helpers#proxy` method, and the pattern of 
an instance of the `haproxy_instance` resource notifying a config-validating 
resource, which in turn notifies the service resource to reload.

### haproxy-ng::install

Installs haproxy via the `node['haproxy']['install_method']` method.

Currently only supports installation from a package.

### haproxy-ng::service

Configures a default-named ("haproxy") service resource. 
Useful if running one haproxy service ("service" in the init-system sense), 
and you have no reason to use a non-default service name. Just create a 
`haproxy_instance` resource named 'haproxy', and include the recipe.


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
        Not fully implemented. One of: ['package', 'source']
      </td>
      <td><code>package</code></td>
    </tr>
    <tr>
      <td>app_role</td>
      <td>
        App role used in `default` recipe for search.
      </td>
      <td><code>app</code></td>
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
        See `library/helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>['daemon']</code></td>
    </tr>
    <tr>
      <td>tuning</td>
      <td>
        Array of global keywords relevant to performance tuning.
        See `library/helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>['maxconn 256']</code></td>
    </tr>
    <tr>
      <td>debug</td>
      <td>
        Global keyword string relevant to debugging (either 'debug', or 'quiet').
        See `library/helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>app</code></td>
    </tr>
    <tr>
      <td>userlists</td>
      <td>
        Not yet implemented.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>peers</td>
      <td>
        Not yet implemented.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>proxies</td>
      <td>
        Array of Chef::Resource::HaproxyProxy instances 
        (`haproxy_{defaults,frontend,backend}` included). See the `default` recipe 
        for an example of using the provided `Haproxy::Helpers#proxy` method to generate
        this list from the resource collection.
      </td>
      <td><code>app</code></td>
    </tr>
  </tbody>
</table>

### haproxy_proxy

The simplest proxy representation and base-class for the other
proxy resources (defaults, frontend, backend, listen).

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
        defaults, frontend, backend, listen.
      </td>
      <td><code>nil</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against specified proxy type.
        See `library/helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_defaults

Maps to a 'defaults' block in haproxy configuration.

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
        See `BALANCE_ALGORITHMS` in libraries/helper.rb or haproxy
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
        See `library/helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_frontend

Maps to a frontend block in the instance configuration, and typically to one or more listening ports.

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
        Array of hashes. Each hash must contain keys `:name`, and `:criterion`.
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
        Array of `Hash`es mapping to a list of `use_backend` directives.
        Each hash is verified to have keys `:backend` and `:condition`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against 'frontend' proxy type.
        See `library/helpers.rb` or haproxy manual for permissible keywords.
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
        Array of hashes. Each hash must contain keys `:name`, and `:criterion`.
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
        See `BALANCE_ALGORITHMS` in libraries/helper.rb or haproxy
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
        Array of `Hashes`. Each `Hash` must contain keys `:name`, `:address`, `:port`,
        and optionally `:config`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against 'backend' proxy type.
        See `library/helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

### haproxy_listen

Maps to a listen configuration block, combines frontend and backend config
blocks into a single proxy.

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
        Array of hashes. Each hash must contain keys `:name`, and `:criterion`.
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
        See `BALANCE_ALGORITHMS` in libraries/helper.rb or haproxy
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
        Array of `Hashes`. Each `Hash` must contain keys `:name`, `:address`, `:port`,
        and optionally `:config`.
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
        Each hash is verified to have keys `:backend` and `:condition`.
      </td>
      <td><code>[]</code></td>
    </tr>
    <tr>
      <td>config</td>
      <td>
        Array of proxy keywords, validated against 'backend' proxy type.
        See `library/helpers.rb` or haproxy manual for permissible keywords.
      </td>
      <td><code>[]</code></td>
    </tr>
  </tbody>
</table>

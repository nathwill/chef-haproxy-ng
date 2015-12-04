# 1.2.0 / 2015-12-03

* fix issue with using attributes as proxy config arg by reading proxy-provider generated stub (thanks @wktmeow)

# 1.1.1 / 2015-11-11

* add config_tail option for adding config after acls (thanks @balexx!)

# 1.1.0 / 2015-09-25

* continuation of config merge fix to handle attributes (thanks @kwilczynski!)
* updated init system handling (added systemd cookbook dependency)

# 1.0.2 / 2015-08-25

* fix config merge when passing an attribute instead of an array (thanks @kwilczynski and @andrewdutton!)

# 1.0.1 / 2015-07-04

* update to haproxy 1.5.14

# 1.0.0 / 2015-06-26

* remove world-readability from config templates
* update to latest source release

# 0.5.2 / 2015-06-24

* add missing requires to libraries
* fix service provider for upstart service with package-install
* update version matching for ark resource

# 0.5.1 / 2015-06-24

* fix compile-time constant initialization warnings
* fix upstart service on EL6

# 0.5.0 / 2015-05-28

* break up the hwrp-supporting modules into smaller pieces
* update source installation to use the ark cookbook

# 0.4.1 / 2015-05-22

* doc updates related to 0.4.0
* fix disabling verification for proxy sub-resources
* demo using consul-template with haproxy-ng

# 0.4.0 / 2015-05-17

* rename validate_at_compile option to 'verify' to adhere to chef norms
* skip instance config verification if 'verify' attribute is false

# 0.3.0 / 2015-05-15

* add ability to disable compile-time validation of proxy/instance
  resources with the "validate_at_compile" resource attribute
* add new verify attribute to instance template when chef > 12;
  replaces validating execute resource
* updated testing/documentation

# 0.2.12 / 2015-05-09

* add extra keyword

# 0.2.11 / 2015-05-07

* explicitly list supported service actions (thanks @alefend)

# 0.2.10 / 2015-05-06

* fix cops
* bump to latest stable haproxy for source build

# 0.2.9 / 2015-04-03

* misc. doc updates
* misc. testing improvements
* backport upstream improvements to systemd service file
* sort servers by name to reduce unnecessary restart/reload

# 0.2.8 / 2015-02-27

* doc updates

# 0.2.7 / 2015-02-27

* unit testing improvements
* fix bind keyword matrix entry

# 0.2.6 / 2015-02-25

* add ppa install method (thanks @elementai!)

# 0.2.5 / 2015-02-25

* fix service setup on fedora when doing source install

# 0.2.4 / 2015-02-23

* fix stick-table entry

# 0.2.3 / 2015-02-19

* add peers resource
* add userlist resource

# 0.2.2 / 2015-02-17

* enable source install
* docs and testing updates

# 0.2.1 / 2015-02-13

* permit abuse of proxy resource for configuration of peers, userlists
* various testing improvements

# 0.2.0 / 2015-02-11

* set type as required attribute for haproxy_proxy resource
* remove default proxy list, proxies recipe
* various and sundry documentation and testing improvements
* add negated keyword equivalents where appropriate

# 0.1.22 / 2015-02-10

* fix Haproxy::Proxy::NonDefaults.merged_config source merge

# 0.1.20 / 2015-02-10

* instance resource filters on actionable proxies
* remove peer/usergroups attrs from instance resource pending actual build-out
* extract default instance config into attributes to make it easier to consume default recipe

# 0.1.18 / 2015-02-09

* add timeout options to redis listen proxy
* move mode attr back into modules

# 0.1.16 / 2015-02-09

* fix balance keyword for DefaultsBackend

# 0.1.14 / 2015-02-09

* add listen resource to default recipe for testing
* move mode attribute under general proxy resource

# 0.1.12 / 2015-02-09

* fix listen provider
* add dummy listen resource to default recipe

# 0.1.10 / 2015-02-09

* use strings as keys

# 0.1.8 / 2015-02-09

* fix option typo

# 0.1.6 / 2015-02-09

* fix type for listen resource

# 0.1.4 / 2015-02-06

* use the correct resource provider for the listener resource

# 0.1.2 / 2015-02-05

* more build-out, consolidation of attributes common to multiple resources

# 0.1.0 / 2015-02-03

* initial release

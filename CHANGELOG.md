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

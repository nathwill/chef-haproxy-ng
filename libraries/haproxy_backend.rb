#
# Cookbook Name: haproxy-ng
# Resource:: backend
#

class Chef::Resource
  class HaproxyBackend < Chef::Resource
    identity_attr :name

  end
end

class Chef::Provider
  class HaproxyBackend < Chef::Provider

  end
end

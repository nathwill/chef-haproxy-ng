#
# Cookbook Name: haproxy-ng
# Resource:: listen
#

class Chef::Resource
  class HaproxyListen < Chef::Resource
    identity_attr :name

  end
end

class Chef::Provider
  class HaproxyListen < Chef::Provider

  end
end

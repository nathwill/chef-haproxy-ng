#
# Cookbook Name: haproxy-ng
# Resource:: defaults
#

class Chef::Resource
  class HaproxyDefaults < Chef::Resource
    identity_attr :name

  end
end

class Chef::Provider
  class HaproxyDefaults < Chef::Provider

  end
end

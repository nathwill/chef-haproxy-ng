#
# Cookbook Name: haproxy-ng
# Resource:: frontend
#

class Chef::Resource
  class HaproxyFrontend < Chef::Resource
    identity_attr :name

  end
end

class Chef::Provider
  class HaproxyFrontend < Chef::Provider

  end
end

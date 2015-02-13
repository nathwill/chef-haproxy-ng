#
# Cookbook Name: haproxy-ng
# Resource:: peers
#

class Chef::Resource
  class HaproxyPeers < Chef::Resource
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_peers
      @provider = Chef::Provider::HaproxyPeers
    end

    def type(_ = nil)
      'peers'
    end
  end
end

#
# Cookbook Name: haproxy-ng
# Provider:: peers
#

class Chef::Provider
  class HaproxyPeers < Chef::Provider
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyPeers.new(new_resource.name)
      @current_resource.type new_resource.type
      @current_resource
    end
  end
end

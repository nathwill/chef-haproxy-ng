#
# Cookbook Name: haproxy-ng
# Resource:: peers
#

class Chef::Resource
  class HaproxyPeers < Chef::Resource::HaproxyProxy
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

class Chef::Provider
  class HaproxyPeers < Chef::Provider::HaproxyProxy
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyPeers.new(new_resource.name)
      @current_resource.type new_resource.type
      @current_resource.config new_resource.config
      @current_resource
    end
  end
end

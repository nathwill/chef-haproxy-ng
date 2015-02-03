#
# Cookbook Name: haproxy-ng
# Resource:: listen
#

class Chef::Resource
  class HaproxyListen < Chef::Resource::HaproxyProxy
    identity_attr :name

    include ::Haproxy::Proxy::All
    include ::Haproxy::Proxy::NonDefaults
    include ::Haproxy::Proxy::DefaultsFrontend
    include ::Haproxy::Proxy::Frontend
    include ::Haproxy::Proxy::DefaultsBackend
    include ::Haproxy::Proxy::Backend

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_frontend
      @provider = Chef::Provider::HaproxyFrontend
    end

    def type(_ = nil)
      'frontend'
    end
  end
end

class Chef::Provider
  class HaproxyListen < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end
  end
end

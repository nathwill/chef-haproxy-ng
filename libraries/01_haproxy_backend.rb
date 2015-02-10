#
# Cookbook Name: haproxy-ng
# Resource:: backend
#

class Chef::Resource
  class HaproxyBackend < Chef::Resource::HaproxyProxy
    identity_attr :name

    include ::Haproxy::Proxy::NonDefaults
    include ::Haproxy::Proxy::DefaultsBackend
    include ::Haproxy::Proxy::Backend

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_backend
      @provider = Chef::Provider::HaproxyBackend
    end

    def type(_ = nil)
      'backend'
    end
  end
end

class Chef::Provider
  class HaproxyBackend < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyBackend.new(
        new_resource.name
      )
      @current_resource.type new_resource.type
      @current_resource.config merged_config(new_resource)
      @current_resource
    end

    private

    def merged_config(r)
      nd = Haproxy::Proxy::NonDefaults.merged_config(r.config, r)
      db_nd = Haproxy::Proxy::DefaultsBackend.merged_config(nd, r)
      Haproxy::Proxy::Backend.merged_config(db_nd, r)
    end
  end
end

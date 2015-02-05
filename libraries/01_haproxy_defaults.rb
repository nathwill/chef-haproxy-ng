#
# Cookbook Name: haproxy-ng
# Resource:: defaults
#

class Chef::Resource
  class HaproxyDefaults < Chef::Resource::HaproxyProxy
    identity_attr :name

    include ::Haproxy::Proxy::All
    include ::Haproxy::Proxy::DefaultsFrontend
    include ::Haproxy::Proxy::DefaultsBackend

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_defaults
      @provider = Chef::Provider::HaproxyDefaults
    end

    def type(_ = nil)
      'defaults'
    end
  end
end

class Chef::Provider
  class HaproxyDefaults < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyDefaults.new(
        new_resource.name
      )
      @current_resource.type new_resource.type
      @current_resource.config merged_config(new_resource)
      @current_resource
    end

    private

    def merged_config
      a = Haproxy::Proxy::All.merged_config(r.config, r)
      df_a = Haproxy::Proxy::DefaultsFrontend.merged_config(a, r)
      Haproxy::Proxy::DefaultsBackend.merged_config(df_a, r)
    end
  end
end

#
# Cookbook Name: haproxy-ng
# Resource:: frontend
#

class Chef::Resource
  class HaproxyFrontend < Chef::Resource::HaproxyProxy
    identity_attr :name

    include ::Haproxy::Proxy::NonDefaults
    include ::Haproxy::Proxy::DefaultsFrontend
    include ::Haproxy::Proxy::Frontend

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
  class HaproxyFrontend < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyFrontend.new(
        new_resource.name
      )
      @current_resource.type new_resource.type
      @current_resource.config merged_config(new_resource)
      @current_resource
    end

    private

    def merged_config(r)
      nd = Haproxy::Proxy::NonDefaults.merged_config(r.config, r)
      df_nd = Haproxy::Proxy::DefaultsFrontend.merged_config(nd, r)
      Haproxy::Proxy::Frontend.merged_config(df_nd, r)
    end
  end
end

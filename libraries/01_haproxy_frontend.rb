#
# Cookbook Name: haproxy-ng
# Resource:: frontend
#

class Chef::Resource
  class HaproxyFrontend < Chef::Resource::HaproxyProxy
    identity_attr :name

    include ::Haproxy::Proxy::All
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
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyFrontend.new(new_resource.name)
      @current_resource.verify new_resource.verify
      @current_resource.type new_resource.type
      @current_resource.config merged_config(new_resource)
      @current_resource
    end

    private

    def merged_config(r)
      a = Haproxy::Proxy::All.merged_config(r.config, r)
      nd_a = Haproxy::Proxy::NonDefaults.merged_config(a, r)
      df_nd_a = Haproxy::Proxy::DefaultsFrontend.merged_config(nd_a, r)
      Haproxy::Proxy::Frontend.merged_config(df_nd_a, r)
    end
  end
end

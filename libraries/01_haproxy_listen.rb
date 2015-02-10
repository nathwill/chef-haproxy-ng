#
# Cookbook Name: haproxy-ng
# Resource:: listen
#

class Chef::Resource
  class HaproxyListen < Chef::Resource::HaproxyProxy
    identity_attr :name

    include ::Haproxy::Proxy::All
    include ::Haproxy::Proxy::NonDefaults
    include ::Haproxy::Proxy::DefaultsBackend
    include ::Haproxy::Proxy::Backend
    include ::Haproxy::Proxy::DefaultsFrontend
    include ::Haproxy::Proxy::Frontend

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_listen
      @provider = Chef::Provider::HaproxyListen
    end

    def type(_ = nil)
      'listen'
    end
  end
end

class Chef::Provider
  class HaproxyListen < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyListen.new(
        new_resource.name
      )
      @current_resource.type new_resource.type
      @current_resource.config merged_config(new_resource)
      @current_resource
    end

    private

    def merged_config(r)
      a = Haproxy::Proxy::All.merged_config(r.config, r)
      nd_a = Haproxy::Proxy::NonDefaults.merged_config(a, r)
      db_nd_a = Haproxy::Proxy::DefaultsBackend.merged_config(nd_a, r)
      b_db_nd_a = Haproxy::Proxy::Backend.merged_config(db_nd_a, r)
      df_b_db_nd_a = Haproxy::Proxy::DefaultsFrontend.merged_config(b_db_nd_a, r)
      Haproxy::Proxy::Frontend.merged_config(df_b_db_nd_a, r)
    end
  end
end

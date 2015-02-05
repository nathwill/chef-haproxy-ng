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
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyFrontend.new(
        new_resource.name
      )
      @current_resource.type new_resource.type
      @current_resource.config merged_config(new_resource.config)
      @current_resource
    end

    private

    # rubocop: disable AbcSize
    # rubocop: disable MethodLength
    def merged_config(config)
      config.unshift("mode #{new_resource.mode}") if new_resource.mode
      Array(new_resource.bind).each do |bind|
        config.unshift("bind #{bind}")
      end
      new_resource.acls.each do |acl|
        config << "acl #{acl[:name]} #{acl[:criterion]}"
      end
      new_resource.use_backends.each do |ub|
        config << "use_backend #{ub[:backend]} #{ub[:condition]}"
      end
      if new_resource.default_backend
        config << "default_backend #{new_resource.default_backend}"
      end
      config
    end
    # rubocop: enable AbcSize
    # rubocop: enable MethodLength
  end
end

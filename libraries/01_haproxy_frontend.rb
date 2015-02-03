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

    # rubocop: disable AbcSize
    # rubocop: disable MethodLength
    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyFrontend.new(
        new_resource.name
      )
      @current_resource.type new_resource.type
      merged_config = new_resource.config
      merged_config.unshift("mode #{new_resource.mode}") if new_resource.mode
      Array(new_resource.bind).each do |bind|
        merged_config.unshift("bind #{bind}")
      end
      new_resource.acls.each do |acl|
        merged_config << "acl #{acl[:name]} #{acl[:criterion]}"
      end
      new_resource.use_backends.each do |ub|
        merged_config << "use_backend #{ub[:backend]} #{ub[:condition]}"
      end
      if new_resource.default_backend
        merged_config << "default_backend #{new_resource.default_backend}"
      end
      @current_resource.config merged_config
      @current_resource
    end
    # rubocop: enable AbcSize
    # rubocop: enable MethodLength
  end
end

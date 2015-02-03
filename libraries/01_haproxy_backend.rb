#
# Cookbook Name: haproxy-ng
# Resource:: backend
#

class Chef::Resource
  class HaproxyBackend < Chef::Resource::HaproxyProxy
    identity_attr :name

    include ::Haproxy::Proxy::All
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

    # rubocop: disable AbcSize
    # rubocop: disable MethodLength
    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyBackend.new(
        new_resource.name
      )
      @current_resource.type new_resource.type
      m = new_resource.config
      {
        'mode' => new_resource.mode,
        'balance' => new_resource.balance
      }.each_pair do |kw, arg|
        m.unshift("#{kw} #{arg}") if arg
      end
      new_resource.servers.each do |s|
        m << "server #{s[:name]} #{s[:address]}:#{s[:port]} #{s[:config]}"
      end
      @current_resource.config m
      @current_resource
    end
    # rubocop: enable AbcSize
    # rubocop: enable MethodLength
  end
end

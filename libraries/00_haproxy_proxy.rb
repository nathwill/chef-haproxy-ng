#
# Cookbook Name: haproxy-ng
# Resource:: instance
#

class Chef::Resource
  class HaproxyProxy < Chef::Resource
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_proxy
      @provider = Chef::Provider::HaproxyProxy
      @action = :create
      @allowed_actions = [:create, :delete]
      @name = name
    end

    def type(arg = nil)
      set_or_return(
        :type, arg,
        :kind_of => String,
        :equal_to => %w( defaults frontend backend listen )
      )
    end

    def config(arg = nil)
      set_or_return(
        :config, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          "is a valid #{type} config" => lambda do |spec|
            Haproxy::Proxy.valid_config?(spec, type)
          end
        }
      )
    end
  end
end

class Chef::Provider
  class HaproxyProxy < Chef::Provider
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyProxy.new(new_resource.name)
      @current_resource.type new_resource.type
      @current_resource.config new_resource.config
      @current_resource
    end

    def action_create
      new_resource.updated_by_last_action(edit_proxy(:create))
    end

    def action_delete
      new_resource.updated_by_last_action(edit_proxy(:delete))
    end

    private

    # rubocop: disable MethodLength
    def edit_proxy(exec_action)
      f = Chef::Resource::File.new(
        "haproxy-#{@current_resource.type}-#{@current_resource.name}",
        run_context
      )
      f.path ::File.join(
        Chef::Config['file_cache_path'] || '/tmp',
        "haproxy.#{@current_resource.type}.#{@current_resource.name}.cfg"
      )
      f.content Haproxy::Proxy.config_block(@current_resource)
      f.run_action exec_action
      f.updated_by_last_action?
    end
    # rubocop: enable MethodLength
  end
end

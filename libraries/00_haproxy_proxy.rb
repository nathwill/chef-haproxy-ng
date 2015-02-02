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
          "is a valid #{self.type} config" => lambda do |spec|
            Haproxy::Proxy.valid_config?(spec, self.type)
          end
        },
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
    end

    def action_create
      new_resource.updated_by_last_action(edit_proxy(:create))
    end

    def action_delete
      new_resource.updated_by_last_action(edit_proxy(:delete))
    end

    private

    def edit_proxy(exec_action)
      f = Chef::Resource::File.new(
        "haproxy-#{new_resource.type}-#{new_resource.name}",
        run_context
      )
      f.path ::File.join(
        "#{Chef::Config['file_cache_path'] || '/tmp'}",
        "haproxy.#{new_resource.type}.#{new_resource.name}.cfg"
      )
      f.content Haproxy::Proxy.config(new_resource)
      f.run_action exec_action
      f.updated_by_last_action?
    end
  end
end

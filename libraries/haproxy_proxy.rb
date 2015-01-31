#
# Cookbook Name: haproxy-ng
# Resource:: instance
#

require 'chef/resource'
require 'chef/provider'

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

    def edit_proxy(exec_action)
        
    end
  end
end

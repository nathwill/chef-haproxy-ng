#
# Cookbook Name: haproxy-ng
# Resource:: userlist
#

class Chef::Resource
  class HaproxyUserlist < Chef::Resource
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_userlist
      @provider = Chef::Provider::HaproxyUserlist
    end

    def type(_ = nil)
      'userlist'
    end
  end
end

#
# Cookbook Name: haproxy-ng
# Provider:: userlist
#

class Chef::Provider
  class HaproxyUserlist < Chef::Provider
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyUserlist.new(new_resource.name)
      @current_resource.type new_resource.type
      @current_resource
    end
  end
end

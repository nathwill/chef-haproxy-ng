#
# Cookbook Name: haproxy-ng
# Resource:: userlist
#

class Chef::Resource
  class HaproxyUserlist < Chef::Resource::HaproxyProxy
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_userlist
      @provider = Chef::Provider::HaproxyUserlist
    end

    def type(_ = nil)
      'userlist'
    end

    # rubocop: disable MethodLength
    def users(arg = nil)
      set_or_return(
        :user, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'valid users list' => lambda do |spec|
            spec.empty? || spec.all? do |u|
              %w( name config ).all? { |a| u.keys.include? a }
            end
          end
        }
      )
    end

    def groups(arg = nil)
      set_or_return(
        :group, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'valid groups list' => lambda do |spec|
            spec.empty? || spec.all? do |g|
              %w( name config ).all? { |a| g.keys.include? a }
            end
          end
        }
      )
    end
    # rubocop: enable MethodLength
  end
end

class Chef::Provider
  class HaproxyUserlist < Chef::Provider::HaproxyProxy
    # rubocop: disable AbcSize
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyUserlist.new(new_resource.name)
      @current_resource.type new_resource.type
      @current_resource.users new_resource.users
      @current_resource.groups new_resource.groups
      @current_resource.config merged_config(new_resource)
      @current_resource
    end
    # rubocop: enable AbcSize

    private

    def merged_config(r)
      conf = r.config
      r.groups.each do |g|
        conf << "group #{g['name']} #{g['config']}"
      end
      r.users.each do |u|
        conf << "user #{u['name']} #{u['config']}"
      end
      conf
    end
  end
end

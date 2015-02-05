#
# Cookbook Name:: haproxy-ng
# Resource:: instance
#

class Chef::Resource
  class HaproxyInstance < Chef::Resource
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @name = name
      @resource_name = :haproxy_instance
      @provider = Chef::Provider::HaproxyInstance
      @allowed_actions = [:create, :delete]
      @action = :create
    end

    def cookbook(arg = nil)
      set_or_return(
        :cookbook, arg,
        :kind_of => String,
        :default => 'haproxy-ng'
      )
    end

    def config(arg = nil)
      set_or_return(
        :config, arg,
        :kind_of => Array,
        :default => %w( daemon ),
        :callbacks => {
          'is a valid config' => lambda do |spec|
            Haproxy::Instance.valid_config?(spec)
          end
        }
      )
    end

    def tuning(arg = nil)
      set_or_return(
        :tuning, arg,
        :kind_of => Array,
        :default => ['maxconn 256'],
        :callbacks => {
          'is a valid tuning' => lambda do |spec|
            Haproxy::Instance.valid_tuning?(spec)
          end
        }
      )
    end

    def debug(arg = nil)
      set_or_return(
        :debug, arg,
        :kind_of => String,
        :equal_to => %w( debug quiet )
      )
    end

    def userlists(arg = nil)
      set_or_return(
        :userlists, arg,
        :kind_of => Hash,
        :default => {},
        :callbacks => {
          'is a valid userlist' => lambda do |spec|
            spec.values.all? { |v| v.start_with?('user', 'group') }
          end
        }
      )
    end

    def peers(arg = nil)
      set_or_return(
        :peers, arg,
        :kind_of => Hash,
        :default => {},
        :callbacks => {
          'is a valid peer list' => lambda do |spec|
            spec # TODO: validate peer configuration
          end
        }
      )
    end

    # List of proxies to pluck from the resource collection
    # when building the instance template. Order matters!
    def proxies(arg = nil)
      set_or_return(
        :proxies, arg,
        :kind_of => Array,
        :default => []
      )
    end
  end
end

#
# Cookbook Name:: haproxy-ng
# Provider:: instance
#

class Chef::Provider
  class HaproxyInstance < Chef::Provider
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyInstance.new(
        new_resource.name
      )
    end

    def action_create
      new_resource.updated_by_last_action(edit_instance(:create))
    end

    def action_delete
      new_resource.updated_by_last_action(edit_instance(:delete))
    end

    private

    # rubocop: disable AbcSize
    def edit_instance(exec_action)
      t = Chef::Resource::Template.new(
        "haproxy-instance-#{new_resource.name}",
        run_context
      )
      t.cookbook new_resource.cookbook
      t.path "/etc/haproxy/#{new_resource.name}.cfg"
      t.source 'haproxy.cfg.erb'
      t.variables :instance => new_resource
      t.run_action exec_action
      t.updated_by_last_action?
    end
    # rubocop: enable AbcSize
  end
end

#
# Cookbook Name: haproxy-ng
# Resource:: backend
#

class Chef::Resource
  class HaproxyBackend < Chef::Resource::HaproxyProxy
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_backend
      @provider = Chef::Provider::HaproxyBackend
      @name = name
    end

    def type
      'backend'
    end

    def balance(arg = nil)
      set_or_return(
        :balance, arg,
        :kind_of => String,
        :default => 'roundrobin',
        :callbacks => {
          'is a valid balance algorithm' => lambda do |spec|
            Haproxy::Backend::BALANCE_ALGORITHMS.any? do |a|
              spec.start_with? a
            end
          end
        }
      )
    end

    def mode(arg = nil)
      set_or_return(
        :mode, arg,
        :kind_of => String,
        :equal_to => Haproxy::MODES,
      )
    end

    def retries(arg = nil)
      set_or_return(
        :retries, arg,
        :kind_of => Integer
      )
    end

    def servers(arg = nil)
      set_or_return(
        :servers, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'is a valid servers list' => lambda do |spec|
             spec.empty? || spec.all? do |s|
               s.is_a? Hash && [:name, :ipaddress, :port].all? do |a|
                 s.keys.include? a
               end
             end
          end
        }
      )
    end
  end
end

class Chef::Provider
  class HaproxyBackend < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyBackend.new(new_resource.name)
    end

    private

    def merge_attribute(attribute, value)
      @current_resource.config.unshift("#{attribute} #{value}") if value
    end

    def edit_proxy(exec_action)
      merge_attribute('mode', new_resource.mode)
      merge_attribute('balance', new_resource.balance)
      merge_attribute('retries', new_resource.retries)
      new_resource.servers.each do |server|
        @current_resource.config.shift(Haproxy::Server.config(server))
      end
      super
    end
  end
end

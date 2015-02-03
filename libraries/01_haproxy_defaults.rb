#
# Cookbook Name: haproxy-ng
# Resource:: defaults
#

class Chef::Resource
  class HaproxyDefaults < Chef::Resource::HaproxyProxy
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_defaults
      @provider = Chef::Provider::HaproxyDefaults
    end

    def type(arg = nil)
      'defaults'
    end

    def balance(arg = nil)
      set_or_return(
        :balance, arg,
        :kind_of => String,
        :default => 'roundrobin',
        :callbacks => {
          'is a valid balance algorithm' => lambda do |spec|
            Haproxy::Proxy::Backend::BALANCE_ALGORITHMS.any? do |a|
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
  end
end

class Chef::Provider
  class HaproxyDefaults < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyDefaults.new(new_resource.name)
      @current_resource.type new_resource.type
      @current_resource.config new_resource.config
      {
        'retries' => new_resource.retries,
        'backlog' => new_resource.backlog,
        'maxconn' => new_resource.maxconn,
        'balance' => new_resource.balance,
        'mode' => new_resource.mode,
      }.each_pair do |kw, val|
        @current_resource.config.unshift("#{kw} #{val}") if val
      end
      @current_resource
    end
  end
end

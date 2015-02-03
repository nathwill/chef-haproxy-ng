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
    end

    def type(arg = nil)
      'backend'
    end

    def balance(arg = nil)
      set_or_return(
        :balance, arg,
        :kind_of => String,
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

    def servers(arg = nil)
      set_or_return(
        :servers, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'is a valid servers list' => lambda do |spec|
             spec.empty? || spec.all? do |s|
               [:name, :address, :port].all? do |a|
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
      @current_resource.type new_resource.type
      merged_config = new_resource.config
      {
        'mode' => new_resource.mode,
        'balance' => new_resource.balance,
      }.each_pair do |kw, arg|
        merged_config.unshift("#{kw} #{arg}") if arg
      end
      new_resource.servers.each do |server|
        merged_config << "server #{server[:name]} #{server[:address]}:#{server[:port]} #{server[:config]}"
      end
      @current_resource.config merged_config
      @current_resource
    end
  end
end

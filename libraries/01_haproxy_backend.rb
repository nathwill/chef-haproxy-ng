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

    def type(_ = nil)
      'backend'
    end

    # rubocop: disable MethodLength
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
    # rubocop: enable MethodLength

    def mode(arg = nil)
      set_or_return(
        :mode, arg,
        :kind_of => String,
        :equal_to => Haproxy::MODES
      )
    end

    # rubocop: disable MethodLength
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
    # rubocop: enable MethodLength
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

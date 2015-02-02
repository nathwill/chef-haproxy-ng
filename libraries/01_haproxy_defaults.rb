#
# Cookbook Name: haproxy-ng
# Resource:: defaults
#

class Chef::Resource
  class HaproxyDefaults < Chef::Resource::HaproxyProxy
    identity_attr :name

    def type
      'defaults'
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

    def backlog(arg = nil)
      set_or_return(
        :backlog, arg,
        :kind_of => Integer
      )
    end

    def maxconn(arg = nil)
       set_or_return(
        :maxconn, arg,
        :kind_of => Integer
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
  end
end

class Chef::Provider
  class HaproxyDefaults < Chef::Provider::Haproxy::Proxy
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyDefaults.new(new_resource.name)
    end

    private

    def merge_attribute(attribute, value)
      @current_resource.config.unshift("#{attribute} #{value}") if value
    end

    def edit_proxy(exec_action)
      merge_attribute('mode', new_resource.mode)
      merge_attribute('balance', new_resource.balance)
      merge_attribute('retries', new_resource.retries)
      merge_attribute('backlog', new_resource.backlog)
      merge_attribute('maxconn', new_resource.maxconn)
      super
    end
  end
end

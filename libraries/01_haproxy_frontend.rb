#
# Cookbook Name: haproxy-ng
# Resource:: frontend
#

class Chef::Resource
  class HaproxyFrontend < Chef::Resource::HaproxyProxy
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_frontend
      @provider = Chef::Provider::HaproxyFrontend
    end

    def type(arg = nil)
      'frontend'
    end

    def acls(arg = nil)
      set_or_return(
        :acls, arg,
        :kind_of => Array,
        :callbacks => {
          'is a valid list of acls' => lambda do |spec|
            spec.all? do |a|
              a.is_a? Hash && [:name, :criterion].all? do |k|
                a.keys.include? k
              end
            end
          end
        }
      )
    end

    def bind(arg = nil)
      set_or_return(
        :bind, arg,
        :kind_of => String,
      )
    end

    def default_backend(arg = nil)
      set_or_return(
        :default_backend, arg,
        :kind_of => String,
        :callbacks => {
          'backend exists' => lambda do |spec|
            Haproxy::Helpers.proxy(spec, run_context)
              .is_a? Chef::Resource::HaproxyProxy
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

    def use_backends(arg = nil)
      set_or_return(
        :use_backends, arg,
        :kind_of => Array,
        :callbacks => {
          'is a valid use_backends list' => lambda do |spec|
            spec.empty? || spec.all? do |u|
              u.is_a? Hash && [:backend, :condition].all? do |a|
                spec.keys.include? a
              end
            end
          end
        }
      )
    end
  end
end

class Chef::Provider
  class HaproxyFrontend < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyFrontend.new(new_resource.name)
      @current_resource.type new_resource.type
      @current_resource.config new_resource.config
      @current_resource
    end
  end
end

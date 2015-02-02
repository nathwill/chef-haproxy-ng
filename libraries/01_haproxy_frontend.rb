#
# Cookbook Name: haproxy-ng
# Resource:: frontend
#

class Chef::Resource
  class HaproxyFrontend < Chef::Resource::HaproxyProxy
    identity_attr :name

    def type
      'frontend'
    end

    def acls(arg = nil)
      set_or_return(
        :acls, arg,
        :kind_of => Array,
        :callbacks => {
          'is a valid list of acls' => lambda do |spec|
            spec.empty? || spec.all? do |a|
              a.is_a? Hash && [:name, :criterion].all? do |k|
                a.keys.include? k
              end
            end
          end
        }
      )
    end

    def backlog(arg = nil)
      set_or_return(
        :backlog, arg,
        :kind_of => Integer,
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
        }
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

    def use_backends(arg = nil)
      set_or_return(
        :use_backends, arg,
        :kind_of => Array,
        :callbacks => {
          'is a valid use_backends list' => lambda do |spec|
            spec.empty? || spec.all? do |u|
              u.is_a? Hash && [:backend, :condition].all? do |a|
                spec.keys.include? a
            end && Haproxy::Helpers.proxy(spec, run_context)
              .is_a? Chef::Resource::HaproxyProxy
          end
        }
      )
    end
  end
end

class Chef::Provider
  class HaproxyFrontend < Chef::Provider
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyFrontend.new(new_resource.name)
    end

    private

    def merge_attribute(attribute, value)
      @current_resource.config.unshift("#{attribute} #{value}") if value
    end

    def edit_proxy(exec_action)
      merge_attribute('default_backend', new_resource.default_backend)
      @current_resource.acls.each do |acl|
        merge_attribute('acl', "#{acl.name} #{acl.criterion} #{acl.config}")
      end
      @current_resource.use_backends.each do |use_backend|
        merge_attribute('use_backend', "#{use_backend.backend} #{use_backend.condition}")
      end
      merge_attribute('backlog', new_resource.backlog)
      merge_attribute('maxconn', new_resource.maxconn)
      merge_attribute('bind', new_resource.bind)
      merge_attribute('mode', new_resource.mode)
      super
    end
  end
end

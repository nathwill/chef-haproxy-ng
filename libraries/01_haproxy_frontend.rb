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

    def type(_ = nil)
      'frontend'
    end

    # rubocop: disable MethodLength
    def acls(arg = nil)
      set_or_return(
        :acls, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'is a valid list of acls' => lambda do |spec|
            spec.all? do |a|
              [:name, :criterion].all? do |k|
                a.keys.include? k
              end
            end
          end
        }
      )
    end
    # rubocop: enable MethodLength

    def bind(arg = nil)
      set_or_return(
        :bind, arg,
        :kind_of => [String, Array]
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
        :equal_to => Haproxy::MODES
      )
    end

    # rubocop: disable MethodLength
    def use_backends(arg = nil)
      set_or_return(
        :use_backends, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'is a valid use_backends list' => lambda do |spec|
            spec.empty? || spec.all? do |u|
              [:backend, :condition].all? do |a|
                u.keys.include? a
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
  class HaproxyFrontend < Chef::Provider::HaproxyProxy
    def initialize(*args)
      super
    end

    # rubocop: disable AbcSize
    # rubocop: disable MethodLength
    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyFrontend.new(
        new_resource.name
      )
      @current_resource.type new_resource.type
      merged_config = new_resource.config
      merged_config.unshift("mode #{new_resource.mode}") if new_resource.mode
      Array(new_resource.bind).each do |bind|
        merged_config.unshift("bind #{bind}")
      end
      new_resource.acls.each do |acl|
        merged_config << "acl #{acl[:name]} #{acl[:criterion]}"
      end
      new_resource.use_backends.each do |ub|
        merged_config << "use_backend #{ub[:backend]} #{ub[:condition]}"
      end
      if new_resource.default_backend
        merged_config << "default_backend #{new_resource.default_backend}"
      end
      @current_resource.config merged_config
      @current_resource
    end
    # rubocop: enable AbcSize
    # rubocop: enable MethodLength
  end
end

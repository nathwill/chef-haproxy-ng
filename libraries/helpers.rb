module Haproxy
  module Helpers
    def self.instances
      self.resource(Chef::Resource::HaproxyInstance)
    end

    def self.instance(name)
      self.instances.select { |i| i.name == name }
    end

    def self.instance_config(instance)
      
    end

    def self.proxies
      self.resource(Chef::Resource::HaproxyProxy)
    end

    def self.proxy(name)
      self.proxies.select { |p| p.name == name }
    end

    def self.proxy_config(proxy)
      
    end

    private def self.resource(resource)
      run_context.resource_collection.select do |r|
        r.is_a?(resource)
      end
    end
  end
end

#
# Cookbook Name: haproxy-ng
# Helpers:: haproxy
#

module Haproxy
  module Helpers
    def self.config(declaration, configuration)
      "#{declaration}\n  #{configuration.join("\n  ")}"
    end

    def self.instance_config(instance)
      config('global', instance.config + instance.tuning)
    end

    def self.proxy_config(proxy)
      config("#{proxy.type} #{proxy.name}", proxy.config)
    end
  end
end

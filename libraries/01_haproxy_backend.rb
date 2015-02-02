#
# Cookbook Name: haproxy-ng
# Resource:: backend
#

class Chef::Resource
  class HaproxyBackend < Chef::Resource::HaproxyProxy
    identity_attr :name

    def type
      'backend'
    end

    def balance
      set_or_return(

      )
    end

    def config
      set_or_return(

      )
    end

    def mode
      set_or_return(

      )
    end

    def retries
      set_or_return(

      )
    end

    def servers
      set_or_return(

      )
    end

    def server_config
      set_or_return(

      )
    end

    def source
      set_or_return(

      )
    end
  end
end

class Chef::Provider
  class HaproxyBackend < Chef::Provider

  end
end

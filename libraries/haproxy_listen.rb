#
# Cookbook Name: haproxy-ng
# Resource:: listen
#

class Chef::Resource
  class HaproxyListen < Chef::Resource
    identity_attr :name

    def acls
      set_or_return(

      )
    end

    def backlog
      set_or_return(

      )
    end

    def bind
      set_or_return(

      )
    end

    def config
      set_or_return(

      )
    end

    def default_backend
      set_or_return(

      )
    end

    def maxconn
      set_or_return(

      )
    end

    def mode
      set_or_return(

      )
    end

    def server_port
      set_or_return(

      )
    end

    def use_backends
      set_or_return(

      )
    end

    def balance
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

    def server_port
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
  class HaproxyListen < Chef::Provider

  end
end

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

    def balance
      set_or_return(

      )
    end

    def backlog
      set_or_return(

      )
    end

    def balance
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

    def retries
      set_or_return(

      )
    end
  end
end

class Chef::Provider
  class HaproxyDefaults < Chef::Provider

  end
end

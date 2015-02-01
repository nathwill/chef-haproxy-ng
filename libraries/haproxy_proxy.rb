#
# Cookbook Name: haproxy-ng
# Resource:: instance
#

require 'chef/resource'
require 'chef/provider'

class Chef::Resource
  class HaproxyProxy < Chef::Resource
    identity_attr :name

    # Keyword valid combos
    PROXY_ALL = %w( defaults frontend listen backend )
    PROXY_DEFAULTS_FRONTEND = %w( defaults frontend listen )
    PROXY_DEFAULTS_BACKEND = %w( defaults backend listen )
    PROXY_FRONTEND = %w( frontend listen )
    PROXY_BACKEND = %w( backend listen )
    PROXY_NON_DEFAULTS = %w( frontend listen backend )

    PROXY_KEYWORD_GRID = {
      'acl' => PROXY_NON_DEFAULTS,
      'appsession' => PROXY_BACKEND,
      'backlog' => PROXY_DEFAULTS_FRONTEND,
      'balance' => PROXY_DEFAULTS_BACKEND,
      'bind' => PROXY_NON_DEFAULTS,
      'bind-process' => PROXY_ALL,
      'block' => PROXY_NON_DEFAULTS,
      'capture cookie' => PROXY_FRONTEND,
      'capture request header' => PROXY_FRONTEND,
      'capture response header' => PROXY_FRONTEND,
      'compression' => PROXY_ALL,
      'cookie' => PROXY_DEFAULTS_BACKEND,
      'default-server' => PROXY_DEFAULTS_BACKEND,
      'default_backend' => PROXY_DEFAULTS_FRONTEND,
      'description' => PROXY_NON_DEFAULTS,
      'disabled' => PROXY_ALL,
      'dispatch' => PROXY_BACKEND,
      'enabled' => PROXY_ALL,
      'errorfile' => PROXY_ALL,
      'errorloc' => PROXY_ALL,
      'errorloc302' => PROXY_ALL,
      'errorloc303' => PROXY_ALL,
      'force-persist' => PROXY_NON_DEFAULTS,
      'fullconn' => PROXY_DEFAULTS_BACKEND,
      'grace' => PROXY_ALL,
      'hash-type' => PROXY_DEFAULTS_BACKEND,
      'http-check disable-on-404' => PROXY_DEFAULTS_BACKEND,
      'http-check expect' => PROXY_BACKEND,
      'http-check send-state' => PROXY_DEFAULTS_BACKEND,
      'http-request' => PROXY_NON_DEFAULTS,
      'http-response' => PROXY_NON_DEFAULTS,
      'http-send-name-header' => PROXY_BACKEND,
      'id' => PROXY_NON_DEFAULTS,
      'ignore-persist' => PROXY_NON_DEFAULTS,
      'log' => PROXY_ALL,
      'max-keep-alive-queue' => PROXY_DEFAULTS_BACKEND,
      'maxconn' => PROXY_DEFAULTS_FRONTEND,
      'mode' => PROXY_ALL,
      'monitor fail' => PROXY_FRONTEND,
      'monitor-net' => PROXY_DEFAULTS_FRONTEND,
      'monitor-uri' => PROXY_DEFAULTS_FRONTEND,
      'option abortonclose' => PROXY_DEFAULTS_BACKEND,
      'option accept-invalid-http-request' => PROXY_DEFAULTS_FRONTEND,
      'option accept-invalid-http-response' => PROXY_DEFAULTS_BACKEND,
      'option allbackups' => PROXY_DEFAULTS_BACKEND,
      'option checkcache' => PROXY_DEFAULTS_BACKEND,
      'option clitcpka' => PROXY_DEFAULTS_FRONTEND,
      'option contstats' => PROXY_DEFAULTS_FRONTEND,
      'option dontlog-normal' => PROXY_DEFAULTS_FRONTEND,
      'option forceclose' => PROXY_ALL,
      'option forwardfor' => PROXY_ALL,
      'option http-keep-alive' => PROXY_ALL,
      'option http-no-delay' => PROXY_ALL,
      'option http-pretend-keepalive' => PROXY_ALL,
      'option http-server-close' => PROXY_ALL,
      'option http-tunnel' => PROXY_ALL,
      'option http-use-proxy-header' => PROXY_DEFAULTS_FRONTEND,
      'option httpchk' => PROXY_DEFAULTS_BACKEND,
      
    }

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_proxy
      @provider = Chef::Provider::HaproxyProxy
      @action = :create
      @allowed_actions = [:create, :delete]
      @name = name
    end

    def type(arg = nil)
      set_or_return(
        :type, arg,
        :kind_of => String,
        :equal_to => %w( defaults frontend backend listen )
      )
    end
  end
end

class Chef::Provider
  class HaproxyProxy < Chef::Provider
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyProxy.new(new_resource.name)
    end

    def action_create
      new_resource.updated_by_last_action(edit_proxy(:create))
    end

    def action_delete
      new_resource.updated_by_last_action(edit_proxy(:delete))
    end

    def edit_proxy(exec_action)
        
    end
  end
end

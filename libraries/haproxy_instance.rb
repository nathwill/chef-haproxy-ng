#
# Cookbook Name:: haproxy-ng
# Resource:: instance
#

require 'chef/resource'
require 'chef/provider'

class Chef::Resource
  class HaproxyInstance < Chef::Resource
    identity_attr :name

    CONFIG_KEYWORDS = %w(
      ca-base
      chroot
      crt-base
      daemon
      uid
      gid
      group
      log
      log-send-hostname
      nbproc
      pidfile
      ulimit-n
      user
      stats
      ssl-server-verify
      node
      description
      unix-bind
    )

    TUNING_KEYWORDS = %w(
      max-spread-checksmaxconn
      maxconnrate
      maxcomprate
      maxcompcpuusage
      maxpipes
      maxsessrate
      maxsslconn
      maxsslrate
      noepoll
      nokqueue
      nopoll
      nosplice
      nogetaddrinfo
      spread-checks
      tune.bufsize
      tune.chksize
      tune.comp.maxlevel
      tune.http.cookielen
      tune.http.maxhdr
      tune.idletimer
      tune.maxaccept
      tune.maxpollevents
      tune.maxrewrite
      tune.pipesize
      tune.rcvbuf.client
      tune.rcvbuf.server
      tune.ssl.cachesize
      tune.ssl.lifetime
      tune.ssl.maxrecord
      tune.ssl.force-private-cache
      tune.ssl.default-dh-param
      tune.zlib.memlevel
      tune.zlib.windowsize
    )

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_instance
      @provider = Chef::Provider::HaproxyInstance
      @action = :create
      @allowed_actions = [:create, :delete]
      @name = name
    end

    def config(arg = nil)
      set_or_return(
        :config, arg,
        :kind_of => Hash,
        :default => {
          'daemon' => nil,
          'maxconn' => 256
        },
        :callbacks => {
          'is a valid config' => lambda do |spec|
            spec.keys.all? { |keyword| CONFIG_KEYWORDS.include? keyword }
          end
        }
      )
    end

    def tuning(arg = nil)
      set_or_return(
        :tuning, arg,
        :kind_of => Hash,
        :callbacks => {
          'is a valid tuning' => lambda do |spec|
            spec.keys.all? { |keyword| TUNING_KEYWORDS.include? keyword }
          end
        }
      )
    end

    def debug(arg = nil)
      set_or_return(
        :debug, arg,
        :kind_of => String,
        :equal_to => %w( debug quiet )
      )
    end

    # List of proxies to pluck from the resource collection
    # when building the instance template. Order matters!
    def proxies(arg = nil)
      set_or_return(
        :proxies, arg,
        :kind_of => Array,
        :default => []
      )
    end
  end
end

#
# Cookbook Name:: haproxy-ng
# Provider:: instance
#

class Chef::Provider
  class HaproxyInstance < Chef::Provider
    def initialize(*args)
      super
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyInstance.new(new_resource.name)
    end

    def action_create
      new_resource.updated_by_last_action(edit_instance(:create))
    end

    def action_delete
      new_resource.updated_by_last_action(edit_instance(:delete))
    end

    def edit_instance(exec_action)
        
    end
  end
end

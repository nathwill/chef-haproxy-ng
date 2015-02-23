#
# Cookbook Name: haproxy-ng
# Helpers:: haproxy
#

module Haproxy
  module Helpers
    def self.config_block(declaration, configuration)
      "#{declaration}\n  #{configuration.join("\n  ")}"
    end

    def self.proxies(run_context)
      resources(Chef::Resource::HaproxyProxy, run_context)
    end

    def self.proxy(name, run_context)
      proxies(run_context).select { |p| p.name == name }.first
    end

    private

    def self.resources(resource, run_context)
      run_context.resource_collection.select do |r|
        r.is_a?(resource)
      end
    end
  end

  module Instance
    CONFIG_KEYWORDS = [
      'ca-base',
      'chroot',
      'cpu-map',
      'crt-base',
      'daemon',
      'gid',
      'group',
      'log',
      'log-send-hostname',
      'log-tag',
      'nbproc',
      'pidfile',
      'ulimit-n',
      'user',
      'ssl-default-bind-ciphers',
      'ssl-default-bind-options',
      'ssl-default-server-ciphers',
      'ssl-default-server-options',
      'ssl-server-verify',
      'stats bind-process',
      'stats socket',
      'stats timeout',
      'stats maxconn',
      'uid',
      'ulimit-n',
      'unix-bind',
      'user',
      'node',
      'description'
    ]

    TUNING_KEYWORDS = %w(
      max-spread-checks
      maxconn
      maxconnrate
      maxcomprate
      maxcompcpuusage
      maxpipes
      maxsessrate
      maxsslconn
      maxsslrate
      maxzlibmem
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
      tune.sndbuf.client
      tune.sndbuf.server
      tune.ssl.cachesize
      tune.ssl.force-private-cache
      tune.ssl.lifetime
      tune.ssl.maxrecord
      tune.ssl.default-dh-param
      tune.zlib.memlevel
      tune.zlib.windowsize
    )

    def self.valid_config?(conf)
      conf.all? do |c|
        Haproxy::Instance::CONFIG_KEYWORDS.any? do |kw|
          c.start_with? kw
        end
      end
    end

    def self.valid_tuning?(conf)
      conf.all? do |c|
        Haproxy::Instance::TUNING_KEYWORDS.any? do |kw|
          c.start_with? kw
        end
      end
    end

    def self.config_block(instance)
      Haproxy::Helpers.config_block('global', instance.config + instance.tuning)
    end
  end

  module Proxy
    MODES = %w( tcp http health )

    PEERS = %w( peers )
    USERLIST = %w( userlist )
    KEYWORD_ALL = %w( defaults frontend listen backend )
    KEYWORD_DEFAULTS_FRONTEND = %w( defaults frontend listen )
    KEYWORD_DEFAULTS_BACKEND = %w( defaults backend listen )
    KEYWORD_FRONTEND = %w( frontend listen )
    KEYWORD_BACKEND = %w( backend listen )
    KEYWORD_NON_DEFAULTS = %w( frontend listen backend )

    KEYWORD_MATRIX = {
      'peer' => PEERS,
      'user' => USERLIST,
      'group' => USERLIST,
      'acl' => KEYWORD_NON_DEFAULTS,
      'appsession' => KEYWORD_BACKEND,
      'backlog' => KEYWORD_DEFAULTS_FRONTEND,
      'balance' => KEYWORD_DEFAULTS_BACKEND,
      'bind' => KEYWORD_NON_DEFAULTS,
      'bind-process' => KEYWORD_ALL,
      'block' => KEYWORD_NON_DEFAULTS,
      'capture cookie' => KEYWORD_FRONTEND,
      'capture request header' => KEYWORD_FRONTEND,
      'capture response header' => KEYWORD_FRONTEND,
      'clitimeout' => KEYWORD_DEFAULTS_FRONTEND,
      'compression algo' => KEYWORD_ALL,
      'compression type' => KEYWORD_ALL,
      'compression offload' => KEYWORD_ALL,
      'contimeout' => KEYWORD_DEFAULTS_BACKEND,
      'cookie' => KEYWORD_DEFAULTS_BACKEND,
      'default-server' => KEYWORD_DEFAULTS_BACKEND,
      'default_backend' => KEYWORD_DEFAULTS_FRONTEND,
      'description' => KEYWORD_NON_DEFAULTS,
      'disabled' => KEYWORD_ALL,
      'dispatch' => KEYWORD_BACKEND,
      'enabled' => KEYWORD_ALL,
      'errorfile' => KEYWORD_ALL,
      'errorloc' => KEYWORD_ALL,
      'errorloc302' => KEYWORD_ALL,
      'errorloc303' => KEYWORD_ALL,
      'force-persist' => KEYWORD_NON_DEFAULTS,
      'fullconn' => KEYWORD_DEFAULTS_BACKEND,
      'grace' => KEYWORD_ALL,
      'hash-type' => KEYWORD_DEFAULTS_BACKEND,
      'http-check disable-on-404' => KEYWORD_DEFAULTS_BACKEND,
      'http-check expect' => KEYWORD_BACKEND,
      'http-check send-state' => KEYWORD_DEFAULTS_BACKEND,
      'http-request' => KEYWORD_NON_DEFAULTS,
      'http-response' => KEYWORD_NON_DEFAULTS,
      'http-send-name-header' => KEYWORD_BACKEND,
      'id' => KEYWORD_NON_DEFAULTS,
      'ignore-persist' => KEYWORD_NON_DEFAULTS,
      'log' => KEYWORD_ALL,
      'no log' => KEYWORD_ALL,
      'log-format' => KEYWORD_DEFAULTS_FRONTEND,
      'max-keep-alive-queue' => KEYWORD_DEFAULTS_BACKEND,
      'maxconn' => KEYWORD_DEFAULTS_FRONTEND,
      'mode' => KEYWORD_ALL,
      'monitor fail' => KEYWORD_FRONTEND,
      'monitor-net' => KEYWORD_DEFAULTS_FRONTEND,
      'monitor-uri' => KEYWORD_DEFAULTS_FRONTEND,
      'option abortonclose' => KEYWORD_DEFAULTS_BACKEND,
      'no option abortonclose' => KEYWORD_DEFAULTS_BACKEND,
      'option accept-invalid-http-request' => KEYWORD_DEFAULTS_FRONTEND,
      'no option accept-invalid-http-request' => KEYWORD_DEFAULTS_FRONTEND,
      'option accept-invalid-http-response' => KEYWORD_DEFAULTS_BACKEND,
      'no option accept-invalid-http-response' => KEYWORD_DEFAULTS_BACKEND,
      'option allbackups' => KEYWORD_DEFAULTS_BACKEND,
      'no option allbackups' => KEYWORD_DEFAULTS_BACKEND,
      'option checkcache' => KEYWORD_DEFAULTS_BACKEND,
      'no option checkcache' => KEYWORD_DEFAULTS_BACKEND,
      'option clitcpka' => KEYWORD_DEFAULTS_FRONTEND,
      'no option clitcpka' => KEYWORD_DEFAULTS_FRONTEND,
      'option contstats' => KEYWORD_DEFAULTS_FRONTEND,
      'option dontlog-normal' => KEYWORD_DEFAULTS_FRONTEND,
      'no option dontlog-normal' => KEYWORD_DEFAULTS_FRONTEND,
      'option dontlognull' => KEYWORD_DEFAULTS_FRONTEND,
      'no option dontlognull' => KEYWORD_DEFAULTS_FRONTEND,
      'option forceclose' => KEYWORD_ALL,
      'no option forceclose' => KEYWORD_ALL,
      'option forwardfor' => KEYWORD_ALL,
      'option http-keep-alive' => KEYWORD_ALL,
      'no option http-keep-alive' => KEYWORD_ALL,
      'option http-no-delay' => KEYWORD_ALL,
      'no option http-no-delay' => KEYWORD_ALL,
      'option http-pretend-keepalive' => KEYWORD_ALL,
      'no option http-pretend-keepalive' => KEYWORD_ALL,
      'option http-server-close' => KEYWORD_ALL,
      'no option http-server-close' => KEYWORD_ALL,
      'option http-tunnel' => KEYWORD_ALL,
      'no option http-tunnel' => KEYWORD_ALL,
      'option http-use-proxy-header' => KEYWORD_DEFAULTS_FRONTEND,
      'no option http-use-proxy-header' => KEYWORD_DEFAULTS_FRONTEND,
      'option httpchk' => KEYWORD_DEFAULTS_BACKEND,
      'option httpclose' => KEYWORD_ALL,
      'no option httpclose' => KEYWORD_ALL,
      'option httplog' => KEYWORD_ALL,
      'option http_proxy' => KEYWORD_ALL,
      'no option http_proxy' => KEYWORD_ALL,
      'option independent-streams' => KEYWORD_ALL,
      'no option independent-streams' => KEYWORD_ALL,
      'option ldap-check' => KEYWORD_DEFAULTS_BACKEND,
      'option log-health-checks' => KEYWORD_DEFAULTS_BACKEND,
      'no option log-health-checks' => KEYWORD_DEFAULTS_BACKEND,
      'option log-separate-errors' => KEYWORD_DEFAULTS_FRONTEND,
      'no option log-separate-errors' => KEYWORD_DEFAULTS_FRONTEND,
      'option logasap' => KEYWORD_DEFAULTS_FRONTEND,
      'no option logasap' => KEYWORD_DEFAULTS_FRONTEND,
      'option mysql-check' => KEYWORD_DEFAULTS_BACKEND,
      'option pgsql-check' => KEYWORD_DEFAULTS_BACKEND,
      'option nolinger' => KEYWORD_ALL,
      'no option nolinger' => KEYWORD_ALL,
      'option originalto' => KEYWORD_ALL,
      'option persist' => KEYWORD_DEFAULTS_BACKEND,
      'no option persist' => KEYWORD_DEFAULTS_BACKEND,
      'option prefer-last-server' => KEYWORD_DEFAULTS_BACKEND,
      'no option prefer-last-server' => KEYWORD_DEFAULTS_BACKEND,
      'option redispatch' => KEYWORD_DEFAULTS_BACKEND,
      'no option redispatch' => KEYWORD_DEFAULTS_BACKEND,
      'option redis-check' => KEYWORD_DEFAULTS_BACKEND,
      'option smtpchk' => KEYWORD_DEFAULTS_BACKEND,
      'option socket-stats' => KEYWORD_DEFAULTS_FRONTEND,
      'no option socket-stats' => KEYWORD_DEFAULTS_FRONTEND,
      'option splice-auto' => KEYWORD_ALL,
      'no option splice-auto' => KEYWORD_ALL,
      'option splice-request' => KEYWORD_ALL,
      'no option splice-request' => KEYWORD_ALL,
      'option splice-response' => KEYWORD_ALL,
      'no option splice-response' => KEYWORD_ALL,
      'option srvtcpka' => KEYWORD_DEFAULTS_BACKEND,
      'no option srvtcpka' => KEYWORD_DEFAULTS_BACKEND,
      'option ssl-hello-chk' => KEYWORD_DEFAULTS_BACKEND,
      'option tcp-check' => KEYWORD_DEFAULTS_BACKEND,
      'option tcp-smart-accept' => KEYWORD_DEFAULTS_FRONTEND,
      'no option tcp-smart-accept' => KEYWORD_DEFAULTS_FRONTEND,
      'option tcp-smart-connect' => KEYWORD_DEFAULTS_BACKEND,
      'no option tcp-smart-connect' => KEYWORD_DEFAULTS_BACKEND,
      'option tcpka' => KEYWORD_ALL,
      'option tcplog' => KEYWORD_ALL,
      'option transparent' => KEYWORD_DEFAULTS_BACKEND,
      'no option transparent' => KEYWORD_DEFAULTS_BACKEND,
      'persist rdp-cookie' => KEYWORD_DEFAULTS_BACKEND,
      'rate-limit sessions' => KEYWORD_DEFAULTS_FRONTEND,
      'redirect location' => KEYWORD_NON_DEFAULTS,
      'redirect prefix' => KEYWORD_NON_DEFAULTS,
      'redirect scheme' => KEYWORD_NON_DEFAULTS,
      'redisp' => KEYWORD_DEFAULTS_BACKEND,
      'redispatch' => KEYWORD_DEFAULTS_BACKEND,
      'reqadd' => KEYWORD_NON_DEFAULTS,
      'reqallow' => KEYWORD_NON_DEFAULTS,
      'reqdel' => KEYWORD_NON_DEFAULTS,
      'reqdeny' => KEYWORD_NON_DEFAULTS,
      'reqiallow' => KEYWORD_NON_DEFAULTS,
      'reqidel' => KEYWORD_NON_DEFAULTS,
      'reqideny' => KEYWORD_NON_DEFAULTS,
      'reqipass' => KEYWORD_NON_DEFAULTS,
      'reqirep' => KEYWORD_NON_DEFAULTS,
      'reqisetbe' => KEYWORD_NON_DEFAULTS,
      'reqitarpit' => KEYWORD_NON_DEFAULTS,
      'reqpass' => KEYWORD_NON_DEFAULTS,
      'reqrep' => KEYWORD_NON_DEFAULTS,
      'reqsetbe' => KEYWORD_NON_DEFAULTS,
      'reqtarpit' => KEYWORD_NON_DEFAULTS,
      'retries' => KEYWORD_DEFAULTS_BACKEND,
      'rspadd' => KEYWORD_NON_DEFAULTS,
      'rspdel' => KEYWORD_NON_DEFAULTS,
      'rspdeny' => KEYWORD_NON_DEFAULTS,
      'rspidel' => KEYWORD_NON_DEFAULTS,
      'rspideny' => KEYWORD_NON_DEFAULTS,
      'rspirep' => KEYWORD_NON_DEFAULTS,
      'rsprep' => KEYWORD_NON_DEFAULTS,
      'server' => KEYWORD_BACKEND,
      'source' => KEYWORD_DEFAULTS_BACKEND,
      'srvtimeout' => KEYWORD_DEFAULTS_BACKEND,
      'stats admin' => KEYWORD_BACKEND,
      'stats auth' => KEYWORD_DEFAULTS_BACKEND,
      'stats enable' => KEYWORD_DEFAULTS_BACKEND,
      'stats hide-version' => KEYWORD_DEFAULTS_BACKEND,
      'stats http-request' => KEYWORD_BACKEND,
      'stats realm' => KEYWORD_DEFAULTS_BACKEND,
      'stats refresh' => KEYWORD_DEFAULTS_BACKEND,
      'stats scope' => KEYWORD_DEFAULTS_BACKEND,
      'stats show-desc' => KEYWORD_DEFAULTS_BACKEND,
      'stats show-legends' => KEYWORD_DEFAULTS_BACKEND,
      'stats show-node' => KEYWORD_DEFAULTS_BACKEND,
      'stats uri' => KEYWORD_DEFAULTS_BACKEND,
      'stick match' => KEYWORD_BACKEND,
      'stick on' => KEYWORD_BACKEND,
      'stick store-request' => KEYWORD_BACKEND,
      'stick store-response' => KEYWORD_BACKEND,
      'stick-table type' => KEYWORD_NON_DEFAULTS,
      'tcp-check connect' => KEYWORD_BACKEND,
      'tcp-check expect' => KEYWORD_BACKEND,
      'tcp-check send' => KEYWORD_BACKEND,
      'tcp-check send-binary' => KEYWORD_BACKEND,
      'tcp-request connection' => KEYWORD_FRONTEND,
      'tcp-request content' => KEYWORD_NON_DEFAULTS,
      'tcp-request inspect-delay' => KEYWORD_NON_DEFAULTS,
      'tcp-response content' => KEYWORD_BACKEND,
      'tcp-response inspect-delay' => KEYWORD_BACKEND,
      'timeout check' => KEYWORD_DEFAULTS_BACKEND,
      'timeout client' => KEYWORD_DEFAULTS_FRONTEND,
      'timeout client-fin' => KEYWORD_DEFAULTS_FRONTEND,
      'timeout clitimeout' => KEYWORD_DEFAULTS_FRONTEND,
      'timeout connect' => KEYWORD_DEFAULTS_BACKEND,
      'timeout contimeout' => KEYWORD_DEFAULTS_BACKEND,
      'timeout http-keep-alive' => KEYWORD_ALL,
      'timeout http-request' => KEYWORD_ALL,
      'timeout queue' => KEYWORD_DEFAULTS_BACKEND,
      'timeout server' => KEYWORD_DEFAULTS_BACKEND,
      'timeout server-fin' => KEYWORD_DEFAULTS_BACKEND,
      'timeout srvtimeout' => KEYWORD_DEFAULTS_BACKEND,
      'timeout tarpit' => KEYWORD_ALL,
      'timeout tunnel' => KEYWORD_DEFAULTS_BACKEND,
      'transparent' => KEYWORD_DEFAULTS_BACKEND,
      'unique-id-format' => KEYWORD_DEFAULTS_FRONTEND,
      'unique-id-header' => KEYWORD_DEFAULTS_FRONTEND,
      'use_backend' => KEYWORD_FRONTEND,
      'use-server' => KEYWORD_BACKEND
    }

    def self.config_block(proxy)
      Haproxy::Helpers.config_block("#{proxy.type} #{proxy.name}", proxy.config)
    end

    def self.valid_config?(config = [], type)
      valid_keywords = KEYWORD_MATRIX.select do |_, v|
        v.include? type
      end

      config.all? do |c|
        valid_keywords.keys.any? { |kw| c.start_with? kw }
      end
    end

    module Frontend
      def bind(arg = nil)
        set_or_return(
          :bind, arg,
          :kind_of => [String, Array]
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
                %w( backend condition ).all? do |a|
                  u.keys.include? a
                end
              end
            end
          }
        )
      end
      # rubocop: enable MethodLength

      def self.merged_config(config, frontend)
        Array(frontend.bind).each do |bind|
          config.unshift("bind #{bind}")
        end
        frontend.use_backends.each do |ub|
          config << "use_backend #{ub['backend']} #{ub['condition']}"
        end
        config
      end
    end

    module DefaultsFrontend
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

      def self.merged_config(conf, df)
        conf << "default_backend #{df.default_backend}" if df.default_backend
        conf
      end
    end

    module Backend
      BALANCE_ALGORITHMS = %w(
        roundrobin
        static-rr
        leastconn
        first
        source
        uri
        url_param
        hdr
        rdp-cookie
      )

      # rubocop: disable MethodLength
      def servers(arg = nil)
        set_or_return(
          :servers, arg,
          :kind_of => Array,
          :default => [],
          :callbacks => {
            'is a valid servers list' => lambda do |spec|
              spec.empty? || spec.all? do |s|
                %w( name address port ).all? do |a|
                  s.keys.include? a
                end
              end
            end
          }
        )
      end
      # rubocop: enable MethodLength

      def self.merged_config(c, backend)
        backend.servers.each do |s|
          c << "server #{s['name']} #{s['address']}:#{s['port']} #{s['config']}"
        end
        c
      end
    end

    module DefaultsBackend
      # rubocop: disable MethodLength
      def balance(arg = nil)
        set_or_return(
          :balance, arg,
          :kind_of => String,
          :callbacks => {
            'is a valid balance algorithm' => lambda do |spec|
              Haproxy::Proxy::Backend::BALANCE_ALGORITHMS.any? do |a|
                spec.start_with? a
              end
            end
          }
        )
      end
      # rubocop: enable MethodLength

      def source(arg = nil)
        set_or_return(
          :source, arg,
          :kind_of => String
        )
      end

      def self.merged_config(conf, db)
        conf.unshift("balance #{db.balance}") if db.balance
        conf << "source #{db.source}" if db.source
        conf
      end
    end

    module NonDefaults
      # rubocop: disable MethodLength
      def acls(arg = nil)
        set_or_return(
          :acls, arg,
          :kind_of => Array,
          :default => [],
          :callbacks => {
            'is a valid list of acls' => lambda do |spec|
              spec.empty? || spec.all? do |a|
                %w( name criterion ).all? do |k|
                  a.keys.include? k
                end
              end
            end
          }
        )
      end
      # rubocop: enable MethodLength

      def description(arg = nil)
        set_or_return(
          :description, arg,
          :kind_of => String
        )
      end

      def self.merged_config(conf, nd)
        conf << "description #{nd.description}" if nd.description
        nd.acls.each do |acl|
          conf << "acl #{acl['name']} #{acl['criterion']}"
        end
        conf
      end
    end

    module All
      def mode(arg = nil)
        set_or_return(
          :mode, arg,
          :kind_of => String,
          :equal_to => Haproxy::Proxy::MODES
        )
      end

      def self.merged_config(conf, proxy)
        conf.unshift("mode #{proxy.mode}") if proxy.mode
        conf
      end
    end
  end
end

#
# Cookbook Name:: haproxy-ng
# Library:: Haproxy::Instance
#
# Author:: Nathan Williams <nath.e.will@gmail.com>
#
# Copyright 2015, Nathan Williams
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require_relative 'haproxy_helpers'

module Haproxy
  module Instance
    CONFIG_KEYWORDS ||= [
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
      'node',
      'description'
    ]

    TUNING_KEYWORDS ||= %w(
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
        CONFIG_KEYWORDS.any? do |kw|
          c.start_with? kw
        end
      end
    end

    def self.valid_tuning?(conf)
      conf.all? do |c|
        TUNING_KEYWORDS.any? do |kw|
          c.start_with? kw
        end
      end
    end

    def self.config_block(instance)
      Haproxy::Helpers.config_block('global', instance.config + instance.tuning)
    end
  end
end

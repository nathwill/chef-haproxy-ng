#
# Cookbook Name:: haproxy-ng
# Library:: Haproxy::Proxy::Backend
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

module Haproxy
  module Proxy
    module Backend
      BALANCE_ALGORITHMS ||= %w(
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
          :servers, arg ? arg.sort_by { |s| s['name'] } : arg,
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

      # rubocop: disable LineLength
      def self.merged_config(config, backend)
        config = Haproxy::Helpers.from_immutable_array(config)
        backend.servers.each do |s|
          config << "server #{s['name']} #{s['address']}:#{s['port']} #{s['config']}"
        end
        config
      end
    end
  end
end

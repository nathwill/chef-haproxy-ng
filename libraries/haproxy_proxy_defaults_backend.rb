#
# Cookbook Name:: haproxy-ng
# Library:: Haproxy::Proxy::DefaultsBackend
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

require_relative 'haproxy_proxy_backend'

module Haproxy
  module Proxy
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

      def self.merged_config(config, backend)
        config = Haproxy::Helpers.from_immutable_array(config)
        config.unshift("balance #{backend.balance}") if backend.balance
        config << "source #{backend.source}" if backend.source
        config
      end
    end
  end
end

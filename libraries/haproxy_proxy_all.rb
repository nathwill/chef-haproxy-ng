#
# Cookbook Name:: haproxy-ng
# Library:: Haproxy::Proxy::All
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

require_relative 'haproxy_proxy'

module Haproxy
  module Proxy
    module All
      def mode(arg = nil)
        set_or_return(
          :mode, arg,
          :kind_of => String,
          :equal_to => Haproxy::Proxy::MODES
        )
      end

      def self.merged_config(config, proxy)
        config = Haproxy::Helpers.from_immutable_array(config)
        config.unshift("mode #{proxy.mode}") if proxy.mode
        config
      end
    end
  end
end

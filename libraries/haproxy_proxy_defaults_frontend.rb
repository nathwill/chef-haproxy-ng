#
# Cookbook Name:: haproxy-ng
# Library:: Haproxy::Proxy::DefaultsFrontend
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
  module Proxy
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

      # rubocop: disable LineLength
      def self.merged_config(config, frontend)
        config = Haproxy::Helpers.from_immutable_array(config)
        config << "default_backend #{frontend.default_backend}" if frontend.default_backend
        config
      end
    end
  end
end

#
# Cookbook Name:: haproxy-ng
# Library:: Chef::Resource::HaproxyProxy,
#           Chef::Provider::HaproxyProxy
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

require 'chef/resource'
require_relative 'haproxy'

class Chef::Resource
  class HaproxyProxy < Chef::Resource::LWRPBase
    include Chef::Mixin::ParamsValidate
    include Haproxy

    resource_name :haproxy_proxy
    provides :haproxy_proxy

    actions :create, :delete
    default_action :create

    def verify(arg = nil)
      set_or_return(
        :verify, arg,
        kind_of: [TrueClass, FalseClass],
        default: true
      )
    end

    def type(arg = nil)
      set_or_return(
        :type, arg,
        kind_of: String,
        required: true,
        equal_to: %w( defaults frontend backend listen peers userlist )
      )
    end

    def config(arg = nil)
      set_or_return(
        :config, arg,
        kind_of: Array, default: [], callbacks: {
          "is a valid #{type} config" => lambda do |spec|
            !verify || Haproxy::Proxy.valid_config?(spec, type)
          end
        }
      )
    end
  end
end

class Chef::Provider
  class HaproxyProxy < Chef::Provider::LWRPBase
    provides :haproxy_proxy

    %i( create delete ).each do |a|
      action a do
        r = new_resource

        path = ::File.join(
          Chef::Config[:file_cache_path] || '/tmp',
          "haproxy.#{r.type}.#{r.name}.cfg"
        )

        f = file path do
          content Haproxy::Proxy.config_block(r)
          action a
        end

        new_resource.updated_by_last_action(f.updated_by_last_action?)
      end
    end
  end
end

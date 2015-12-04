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
  class HaproxyProxy < Chef::Resource
    include Haproxy

    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @name = name
      @resource_name = :haproxy_proxy
      @provider = Chef::Provider::HaproxyProxy
      @allowed_actions = [:create, :delete]
      @action = :create
    end

    def type(arg = nil)
      set_or_return(
        :type, arg,
        :required => true,
        :kind_of => String,
        :equal_to => %w( defaults frontend backend listen peers userlist )
      )
    end

    def config(arg = nil)
      set_or_return(
        :config, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          "is a valid #{type} config" => lambda do |spec|
            !verify || Haproxy::Proxy.valid_config?(spec, type)
          end
        }
      )
    end

    def verify(arg = nil)
      set_or_return(
        :verify, arg,
        :kind_of => [TrueClass, FalseClass],
        :default => true
      )
    end
  end
end

class Chef::Provider
  class HaproxyProxy < Chef::Provider
    def initialize(*args)
      super
      @proxy_file = Chef::Resource::File.new(
        "haproxy-#{new_resource.type}-#{new_resource.name}",
        run_context
      )
    end

    def load_current_resource
      @current_resource ||= Chef::Resource::HaproxyProxy.new(new_resource.name)
      @current_resource.verify new_resource.verify
      @current_resource.type new_resource.type
      @current_resource.config new_resource.config
      @current_resource
    end

    def action_create
      new_resource.updated_by_last_action(edit_proxy(:create))
    end

    def action_delete
      new_resource.updated_by_last_action(edit_proxy(:delete))
    end

    private

    def edit_proxy(exec_action)
      @proxy_file.mode '0640'
      @proxy_file.path ::File.join(
        Chef::Config['file_cache_path'] || '/tmp',
        "haproxy.#{@current_resource.type}.#{@current_resource.name}.cfg"
      )
      @proxy_file.content Haproxy::Proxy.config_block(@current_resource)
      @proxy_file.run_action exec_action
      @proxy_file.updated_by_last_action?
    end
  end
end

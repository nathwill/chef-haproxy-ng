#
# Cookbook Name:: haproxy-ng
# Library:: Chef::Resource::HaproxyDefaults,
#           Chef::Provider::HaproxyDefaults
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

require_relative 'chef_haproxy_proxy'

class Chef::Resource
  class HaproxyDefaults < Chef::Resource::HaproxyProxy
    identity_attr :name

    include ::Haproxy::Proxy::All
    include ::Haproxy::Proxy::DefaultsFrontend
    include ::Haproxy::Proxy::DefaultsBackend

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_defaults
      @provider = Chef::Provider::HaproxyDefaults
    end

    def type(_ = nil)
      'defaults'
    end
  end
end

class Chef::Provider
  class HaproxyDefaults < Chef::Provider::HaproxyProxy
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyDefaults.new(new_resource.name)
      @current_resource.verify new_resource.verify
      @current_resource.type new_resource.type
      @current_resource.config merged_config(new_resource)
      @current_resource
    end

    private

    def merged_config(r)
      a = Haproxy::Proxy::All.merged_config(r.config, r)
      df_a = Haproxy::Proxy::DefaultsFrontend.merged_config(a, r)
      Haproxy::Proxy::DefaultsBackend.merged_config(df_a, r)
    end
  end
end

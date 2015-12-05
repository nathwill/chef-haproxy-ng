#
# Cookbook Name:: haproxy-ng
# Library:: Chef::Resource::HaproxyBackend,
#           Chef::Provider::HaproxyBackend
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
  class HaproxyBackend < Chef::Resource::HaproxyProxy
    resource_name :haproxy_backend

    include ::Haproxy::Proxy::All
    include ::Haproxy::Proxy::NonDefaults
    include ::Haproxy::Proxy::DefaultsBackend
    include ::Haproxy::Proxy::Backend

    def type(_ = nil)
      'backend'
    end
  end
end

class Chef::Provider
  class HaproxyBackend < Chef::Provider::HaproxyProxy
    provides :haproxy_backend

    private

    def merged_config(r)
      a = Haproxy::Proxy::All.merged_config(r.config, r)
      nd_a = Haproxy::Proxy::NonDefaults.merged_config(a, r)
      db_nd_a = Haproxy::Proxy::DefaultsBackend.merged_config(nd_a, r)
      Haproxy::Proxy::Backend.merged_config(db_nd_a, r)
    end
  end
end

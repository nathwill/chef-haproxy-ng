#
# Cookbook Name:: haproxy-ng
# Library:: Chef::Resource::HaproxyPeers,
#           Chef::Provider::HaproxyPeers
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
  class HaproxyPeers < Chef::Resource::HaproxyProxy
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_peers
      @provider = Chef::Provider::HaproxyPeers
    end

    def type(_ = nil)
      'peers'
    end

    # rubocop: disable MethodLength
    def peers(arg = nil)
      set_or_return(
        :peers, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'valid peers list' => lambda do |spec|
            spec.empty? || spec.all? do |p|
              %w( name address port ).all? { |a| p.keys.include? a }
            end
          end
        }
      )
    end
    # rubocop: enable MethodLength
  end
end

class Chef::Provider
  class HaproxyPeers < Chef::Provider::HaproxyProxy
    # rubocop: disable AbcSize
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyPeers.new(new_resource.name)
      @current_resource.verify new_resource.verify
      @current_resource.type new_resource.type
      @current_resource.peers new_resource.peers
      @current_resource.config merged_config(new_resource)
      @current_resource
    end
    # rubocop: enable AbcSize

    private

    def merged_config(r)
      conf = r.config
      r.peers.each do |p|
        conf << "peer #{p['name']} #{p['address']}:#{p['port']}"
      end
      conf
    end
  end
end

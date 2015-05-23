#
# Cookbook Name:: haproxy-ng
# Library:: Chef::Resource::HaproxyUserlist,
#           Chef::Provider::HaproxyUserlist
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

class Chef::Resource
  class HaproxyUserlist < Chef::Resource::HaproxyProxy
    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @resource_name = :haproxy_userlist
      @provider = Chef::Provider::HaproxyUserlist
    end

    def type(_ = nil)
      'userlist'
    end

    # rubocop: disable MethodLength
    def users(arg = nil)
      set_or_return(
        :user, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'valid users list' => lambda do |spec|
            spec.empty? || spec.all? do |u|
              %w( name config ).all? { |a| u.keys.include? a }
            end
          end
        }
      )
    end

    def groups(arg = nil)
      set_or_return(
        :group, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'valid groups list' => lambda do |spec|
            spec.empty? || spec.all? do |g|
              %w( name config ).all? { |a| g.keys.include? a }
            end
          end
        }
      )
    end
    # rubocop: enable MethodLength
  end
end

class Chef::Provider
  class HaproxyUserlist < Chef::Provider::HaproxyProxy
    # rubocop: disable AbcSize
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyUserlist.new(new_resource.name)
      @current_resource.verify new_resource.verify
      @current_resource.type new_resource.type
      @current_resource.users new_resource.users
      @current_resource.groups new_resource.groups
      @current_resource.config merged_config(new_resource)
      @current_resource
    end
    # rubocop: enable AbcSize

    private

    def merged_config(r)
      conf = r.config
      r.groups.each do |g|
        conf << "group #{g['name']} #{g['config']}"
      end
      r.users.each do |u|
        conf << "user #{u['name']} #{u['config']}"
      end
      conf
    end
  end
end

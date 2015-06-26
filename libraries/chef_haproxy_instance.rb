#
# Cookbook Name:: haproxy-ng
# Library:: Chef::Resource::HaproxyInstance,
#           Chef::Provider::HaproxyInstance
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

require_relative 'haproxy'

class Chef::Resource
  class HaproxyInstance < Chef::Resource
    include Haproxy

    identity_attr :name

    def initialize(name, run_context = nil)
      super
      @name = name
      @resource_name = :haproxy_instance
      @provider = Chef::Provider::HaproxyInstance
      @allowed_actions = [:create, :delete]
      @action = :create
    end

    def cookbook(arg = nil)
      set_or_return(
        :cookbook, arg,
        :kind_of => String,
        :default => 'haproxy-ng'
      )
    end

    def config(arg = nil)
      set_or_return(
        :config, arg,
        :kind_of => Array,
        :default => %w( daemon ),
        :callbacks => {
          'is a valid config' => lambda do |spec|
            !verify || Haproxy::Instance.valid_config?(spec)
          end
        }
      )
    end

    def tuning(arg = nil)
      set_or_return(
        :tuning, arg,
        :kind_of => Array,
        :default => ['maxconn 256'],
        :callbacks => {
          'is a valid tuning' => lambda do |spec|
            !verify || Haproxy::Instance.valid_tuning?(spec)
          end
        }
      )
    end

    def debug(arg = nil)
      set_or_return(
        :debug, arg,
        :kind_of => String,
        :equal_to => %w( debug quiet )
      )
    end

    def proxies(arg = nil)
      set_or_return(
        :proxies, arg,
        :kind_of => Array,
        :default => [],
        :callbacks => {
          'is a valid proxy list' => lambda do |spec|
            spec.all? { |p| p.is_a? Chef::Resource::HaproxyProxy }
          end
        }
      )
    end
  end
end

#
# Cookbook Name:: haproxy-ng
# Provider:: instance
#

class Chef::Provider
  class HaproxyInstance < Chef::Provider
    def initialize(*args)
      super
      @tpl = Chef::Resource::Template.new(
        "haproxy-instance-#{new_resource.name}",
        run_context
      )
    end

    # rubocop: disable AbcSize
    def load_current_resource
      @current_resource ||=
        Chef::Resource::HaproxyInstance.new(new_resource.name)
      @current_resource.verify new_resource.verify
      @current_resource.cookbook new_resource.cookbook
      @current_resource.config new_resource.config
      @current_resource.tuning new_resource.tuning
      @current_resource.debug new_resource.debug
      @current_resource.proxies actionable_proxies(new_resource.proxies)
      @current_resource
    end
    # rubocop: enable AbcSize

    def action_create
      new_resource.updated_by_last_action(edit_instance(:create))
    end

    def action_delete
      new_resource.updated_by_last_action(edit_instance(:delete))
    end

    private

    def actionable_proxies(proxies)
      proxies.select do |p|
        p.action == :create && !p.should_skip?(new_resource.action)
      end
    end

    def edit_instance(exec_action)
      @tpl.cookbook @current_resource.cookbook
      @tpl.mode '0640'
      @tpl.path "/etc/haproxy/#{@current_resource.name}.cfg"
      @tpl.source 'haproxy.cfg.erb'
      @tpl.variables :instance => @current_resource
      if @current_resource.verify && (Chef::VERSION.to_f >= 12)
        @tpl.verify { |path| "haproxy -q -c -f #{path}" }
      end
      @tpl.run_action exec_action
      @tpl.updated_by_last_action?
    end
  end
end

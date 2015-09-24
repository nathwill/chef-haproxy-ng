#
# Cookbook Name:: haproxy-ng
# Library:: Haproxy::Helpers
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

module Haproxy
  module Helpers
    def self.config_block(declaration, configuration)
      "#{declaration}\n  #{configuration.join("\n  ")}"
    end

    def self.proxies(run_context)
      resources(Chef::Resource::HaproxyProxy, run_context)
    end

    def self.proxy(name, run_context)
      proxies(run_context).find { |p| p.name == name }
    end

    def self.from_immutable_array(value)
      value.is_a?(Chef::Node::ImmutableArray) ? value.to_a : value
    end

    private

    def self.resources(resource, run_context)
      run_context.resource_collection.select do |r|
        r.is_a?(resource)
      end
    end
  end
end

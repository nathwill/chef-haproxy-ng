#
# Cookbook Name:: haproxy-ng
# Library:: Haproxy::Proxy::NonDefaults
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
  module Proxy
    module NonDefaults
      # rubocop: disable MethodLength
      def acls(arg = nil)
        set_or_return(
          :acls, arg,
          :kind_of => Array,
          :default => [],
          :callbacks => {
            'is a valid list of acls' => lambda do |spec|
              spec.empty? || spec.all? do |a|
                %w( name criterion ).all? do |k|
                  a.keys.include? k
                end
              end
            end
          }
        )
      end
      # rubocop: enable MethodLength

      def config_tail(arg = nil)
        set_or_return(
          :config_tail, arg,
          :kind_of => Array,
          :default => [],
          :callbacks => {
            'is a valid config' => lambda do |spec|
              !verify || Haproxy::Proxy.valid_config?(spec, type)
            end
          }
        )
      end

      def description(arg = nil)
        set_or_return(
          :description, arg,
          :kind_of => String
        )
      end

      def self.merged_config(config, non_defaults)
        config = Haproxy::Helpers.from_immutable_array(config)
        config << "description #{non_defaults.description}" if non_defaults.description # rubocop: disable LineLength
        non_defaults.acls.each do |acl|
          config << "acl #{acl['name']} #{acl['criterion']}"
        end
        non_defaults.config_tail.each do |cnf|
          config << cnf
        end
        config
      end
    end
  end
end

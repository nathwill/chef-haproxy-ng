#
# Cookbook Name:: haproxy-ng
# Library:: Haproxy::Proxy::Frontend
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
    module Frontend
      def bind(arg = nil)
        set_or_return(
          :bind, arg,
          :kind_of => [String, Array]
        )
      end

      # rubocop: disable MethodLength
      def use_backends(arg = nil)
        set_or_return(
          :use_backends, arg,
          :kind_of => Array,
          :default => [],
          :callbacks => {
            'is a valid use_backends list' => lambda do |spec|
              spec.empty? || spec.all? do |u|
                %w( backend condition ).all? do |a|
                  u.keys.include? a
                end
              end
            end
          }
        )
      end
      # rubocop: enable MethodLength

      def self.merged_config(config, frontend)
        config = Haproxy::Helpers.from_immutable_array(config)
        Array(frontend.bind).each do |bind|
          config.unshift("bind #{bind}")
        end
        frontend.use_backends.each do |ub|
          config << "use_backend #{ub['backend']} #{ub['condition']}"
        end
        config
      end
    end
  end
end

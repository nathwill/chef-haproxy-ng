#
# Cookbook Name:: haproxy-ng
# Spec:: install
#
# Copyright 2015 Nathan Williams
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


require 'spec_helper'

describe 'haproxy-ng::service' do

  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      ChefSpec::ServerRunner.new.converge(described_recipe)
    end

    it 'enables service' do
      expect(chef_run).to enable_service 'haproxy'
    end

    it 'starts service' do
      expect(chef_run).to start_service 'haproxy'
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'Ubuntu' do
    let(:chef_run) do
      ChefSpec::ServerRunner
        .new(platform: 'ubuntu', version: '14.04')
        .converge(described_recipe)
    end

    it 'enables service to start/disables defaults fuckery' do
      expect(chef_run).to create_cookbook_file '/etc/default/haproxy'
    end

    it 'converges successfully' do
      chef_run
    end
  end
end

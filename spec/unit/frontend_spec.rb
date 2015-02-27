require 'spec_helper'

describe Haproxy::Proxy::Frontend do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_frontend) do
    r = Chef::Resource::HaproxyFrontend.new('app', chef_run.run_context)
    r.config ['option clitcpka']
    r.bind '*:80'
    r.use_backends [{'backend' => 'dummy', 'condition' => 'if dummy'}]
    r
  end

  it 'returns a valid merged config' do
    expect(
      Haproxy::Proxy::Frontend
        .merged_config(dummy_frontend.config, dummy_frontend)
    ).to match_array ['bind *:80', 'option clitcpka', 'use_backend dummy if dummy']
  end
end

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

  it 'works with Chef attributes' do
    chef_run.node.default['dummy']['attribute'] = [
      'timeout http-keep-alive 10s',
      'timeout http-request 30s'
    ]

    expect(chef_run.node['dummy']['attribute']).to be_a Chef::Node::ImmutableArray

    expect(
      Haproxy::Proxy::Frontend
        .merged_config(chef_run.node['dummy']['attribute'], dummy_frontend)
    ).to match_array [
      'bind *:80',
      'use_backend dummy if dummy',
      'timeout http-keep-alive 10s',
      'timeout http-request 30s'
    ]
  end
end

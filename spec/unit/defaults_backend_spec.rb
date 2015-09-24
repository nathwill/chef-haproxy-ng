require 'spec_helper'

describe Haproxy::Proxy::DefaultsBackend do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_backend) do
    r = Chef::Resource::HaproxyBackend.new('web', chef_run.run_context)
    r.config ['fullconn 100']
    r.balance 'roundrobin'
    r.source '1.2.3.4'
    r
  end

  it 'returns a valid merged config' do
    expect(
      Haproxy::Proxy::DefaultsBackend
        .merged_config(dummy_backend.config, dummy_backend)
    ).to match_array ['fullconn 100', 'balance roundrobin', 'source 1.2.3.4']
  end

  it 'works with Chef attributes' do
    chef_run.node.default['dummy']['attribute'] = [
      'timeout connect 10s',
      'timeout server 30s'
    ]

    expect(chef_run.node['dummy']['attribute']).to be_a Chef::Node::ImmutableArray

    expect(
      Haproxy::Proxy::DefaultsBackend
        .merged_config(chef_run.node['dummy']['attribute'], dummy_backend)
    ).to match_array [
      'balance roundrobin',
      'source 1.2.3.4',
      'timeout connect 10s',
      'timeout server 30s'
    ]
  end
end

require 'spec_helper'

describe Haproxy::Proxy::All do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_defaults) do
    r = Chef::Resource::HaproxyDefaults.new('http', chef_run.run_context)
    r.config ['option clitcpka']
    r.mode 'http'
    r
  end

  it 'creates a valid merged config' do
    expect(
      Haproxy::Proxy::All
        .merged_config(dummy_defaults.config, dummy_defaults)
    ).to match_array ['mode http', 'option clitcpka']
  end

  it 'works with Chef attributes' do
    chef_run.node.default['dummy']['attribute'] = [
      'timeout client 3h',
      'timeout server 6h'
    ]

    expect(chef_run.node['dummy']['attribute']).to be_a Chef::Node::ImmutableArray

    expect(
      Haproxy::Proxy::All
        .merged_config(chef_run.node['dummy']['attribute'], dummy_defaults)
    ).to match_array ['mode http', 'timeout client 3h','timeout server 6h']
  end
end

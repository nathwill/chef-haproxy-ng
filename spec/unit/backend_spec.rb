require 'spec_helper'

describe Haproxy::Proxy::Backend do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_backend) do
    r = Chef::Resource::HaproxyBackend.new('web', chef_run.run_context)
    r.config ['fullconn 100']
    r.servers [
      { 'name' => 'app02', 'address' => '1.2.3.5', 'port' => 80, 'config' => 'backup' },
      { 'name' => 'app01', 'address' => '1.2.3.4', 'port' => 80, 'config' => 'backup' }
    ]
    r
  end

  it 'returns a valid, server-sorted merged config' do
    expect(
      Haproxy::Proxy::Backend
        .merged_config(dummy_backend.config, dummy_backend)
    ).to eq(['fullconn 100', 'server app01 1.2.3.4:80 backup', 'server app02 1.2.3.5:80 backup'])
  end

  it 'works with Chef attributes' do
    chef_run.node.default['dummy']['attribute'] = [
      'tcp-check connect',
      'tcp-check expect'
    ]

    expect(chef_run.node['dummy']['attribute']).to be_a Chef::Node::ImmutableArray

    expect(
      Haproxy::Proxy::Backend
        .merged_config(chef_run.node['dummy']['attribute'], dummy_backend)
    ).to match_array [
      'server app01 1.2.3.4:80 backup',
      'server app02 1.2.3.5:80 backup',
      'tcp-check connect',
      'tcp-check expect'
    ]
  end
end

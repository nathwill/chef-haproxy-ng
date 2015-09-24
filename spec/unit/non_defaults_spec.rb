require 'spec_helper'

describe Haproxy::Proxy::NonDefaults do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_listen) do
    r = Chef::Resource::HaproxyListen.new('redis', chef_run.run_context)
    r.config ['bind *:80']
    r.acls [{ 'name' => 'redis', 'criterion' => 'src 1.2.3.4' }]
    r.description 'redis cluster'
    r
  end

  it 'returns a valid merged config' do
    expect(
      Haproxy::Proxy::NonDefaults
        .merged_config(dummy_listen.config, dummy_listen)
    ).to match_array ['bind *:80', 'description redis cluster', 'acl redis src 1.2.3.4']
  end

  it 'works with Chef attributes' do
    chef_run.node.default['dummy']['attribute'] = [
      'hash-type consistent',
      'ignore-persist if redis'
    ]

    expect(chef_run.node['dummy']['attribute']).to be_a Chef::Node::ImmutableArray

    expect(
      Haproxy::Proxy::NonDefaults
        .merged_config(chef_run.node['dummy']['attribute'], dummy_listen)
    ).to match_array [
      'description redis cluster',
      'acl redis src 1.2.3.4',
      'hash-type consistent',
      'ignore-persist if redis'
    ]
  end
end

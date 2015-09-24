require 'spec_helper'

describe Haproxy::Proxy::DefaultsFrontend do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_frontend) do
    r = Chef::Resource::HaproxyFrontend.new('web', chef_run.run_context)
    r.config ['bind *:80']
    r.default_backend 'app'
    r
  end

  it 'returns a valid merged config' do
    expect(
      Haproxy::Proxy::DefaultsFrontend
        .merged_config(dummy_frontend.config, dummy_frontend)
    ).to match_array ['bind *:80', 'default_backend app']
  end

  it 'works with Chef attributes' do
    chef_run.node.default['dummy']['attribute'] = [
      'option tcpka',
      'option tcplog'
    ]

    expect(chef_run.node['dummy']['attribute']).to be_a Chef::Node::ImmutableArray

    expect(
      Haproxy::Proxy::Frontend
        .merged_config(chef_run.node['dummy']['attribute'], dummy_frontend)
    ).to match_array ['option tcpka', 'option tcplog']
  end
end

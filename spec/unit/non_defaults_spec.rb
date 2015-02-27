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
end

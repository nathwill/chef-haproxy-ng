require 'spec_helper'

describe Haproxy::Proxy::Backend do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_backend) do
    r = Chef::Resource::HaproxyBackend.new('web', chef_run.run_context)
    r.config ['fullconn 100']
    r.servers [
      { 'name' => 'app01', 'address' => '1.2.3.4', 'port' => 80, 'config' => 'backup' }
    ]
    r
  end

  it 'returns a valid merged config' do
    expect(
      Haproxy::Proxy::Backend
        .merged_config(dummy_backend.config, dummy_backend)
    ).to match_array ['fullconn 100', 'server app01 1.2.3.4:80 backup']
  end
end

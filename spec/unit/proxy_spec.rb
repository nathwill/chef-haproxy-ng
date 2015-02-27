require 'spec_helper'

describe Haproxy::Proxy do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_proxy) do
    r = Chef::Resource::HaproxyProxy.new('app', chef_run.run_context)
    r.type 'frontend'
    r.config ['bind *:80']
    r
  end

  it 'returns a valid config block' do
    expect(
      Haproxy::Proxy.config_block(dummy_proxy)
    ).to eq "frontend app\n  bind *:80"
  end

  it 'validates proxy configuration' do
    expect(Haproxy::Proxy.valid_config?(['bind *:80'], 'frontend')).to eq true
    expect(Haproxy::Proxy.valid_config?(['bind *:80'], 'backend')).to eq false
  end  
end

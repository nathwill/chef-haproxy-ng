require 'spec_helper'

describe Haproxy::Proxy::All do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_defaults) do
    r = Chef::Resource::HaproxyDefaults.new('http', chef_run.run_context)
    r.mode 'http'
    r
  end

  it 'creates a valid merged config' do
    expect(
      Haproxy::Proxy::All
        .merged_config(dummy_defaults.config, dummy_defaults)
    ).to match_array ['mode http']
  end
end

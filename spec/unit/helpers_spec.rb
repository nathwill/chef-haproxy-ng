require 'spec_helper'

describe Haproxy::Helpers do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:immutable_array) { Chef::Node::ImmutableArray.new([1, 'a', {}]) }

  it 'returns a valid config block' do
    expect(
      Haproxy::Helpers.config_block('frontend app', ['bind *:80', 'mode http'])
    ).to eq "frontend app\n  bind *:80\n  mode http"
  end

  it 'locates proxies in the resource_collection' do
    expect(
      Haproxy::Helpers.proxy('app', chef_run.run_context)
    ).to be_a(Chef::Resource::HaproxyProxy)
  end

  it 'returns an Array given Chef::Node::ImmutableArray' do
    expect(
      Haproxy::Helpers.from_immutable_array(immutable_array)
    ).to be_a(Array)

    expect(
      Haproxy::Helpers.from_immutable_array(immutable_array)
    ).to match_array [1, 'a', {}]
  end
end

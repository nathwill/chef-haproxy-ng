require 'spec_helper'

describe Haproxy::Instance do
  let(:chef_run) { ChefSpec::ServerRunner.new.converge('my-lb::default') }
  let(:dummy_instance) do
    Chef::Resource::HaproxyInstance.new('dummy', chef_run.run_context)
  end

  it 'defines accepted config keywords' do
    expect(Haproxy::Instance::CONFIG_KEYWORDS).to be_an Array
  end

  it 'defines accepted tuning keywords' do
    expect(Haproxy::Instance::TUNING_KEYWORDS).to be_an Array
  end

  it 'identifies valid configs' do
    expect(Haproxy::Instance.valid_config?( ['daemon'] ) ).to eq true
    expect(Haproxy::Instance.valid_config?( ['demon'] ) ).to eq false
  end

  it 'identifies valid tunings' do
    expect(Haproxy::Instance.valid_tuning?( ['maxconn 200'] ) ).to eq true
    expect(Haproxy::Instance.valid_tuning?( ['maxcnon 200'] ) ).to eq false
  end

  it 'returns a valid global config block' do
    expect(
      Haproxy::Instance.config_block(dummy_instance)
    ).to eq "global\n  daemon\n  maxconn 256"
  end
end

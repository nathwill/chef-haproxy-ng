require 'spec_helper'

describe 'haproxy-ng::default' do
  describe 'configures the apt ppa' do
    describe file('/etc/apt/sources.list.d/haproxy.list') do
      its(:content) { should match /vbernat\/haproxy-1.5/ }
    end
  end

  describe 'installs haproxy' do
    describe package('haproxy') do
      it { should be_installed }
    end
  end
end

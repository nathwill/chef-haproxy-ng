require 'spec_helper'

describe 'haproxy-ng::default' do
  describe 'installs haproxy' do
    describe package('haproxy') do
      it { should be_installed }
    end
  end

  describe 'configures haproxy' do
    describe file('/etc/haproxy/haproxy.cfg') do
      its(:md5sum) { should eq '0849994f1ee87a04ec22b7c2a674a41d' }
    end
  end

  describe 'manages haproxy service' do
    describe service('haproxy') do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe 'configures individual proxies correctly' do
    {
      'haproxy.defaults.HTTP.cfg' => '95fb6e5187ec16401fbdef786c622399',
      'haproxy.frontend.www.cfg' => 'de6616e18e200c8d6704297a51efd0e5',
      'haproxy.backend.app.cfg' => 'a23c89d6a99172fc425482161935e893',
    }.each_pair do |f, s|
      describe file("/tmp/kitchen/cache/#{f}") do
        its(:md5sum) { should eq s }
      end
    end
  end
end

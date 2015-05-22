require 'spec_helper'

describe 'my-consul-lb' do
  describe 'sets up consul' do
    describe service('consul') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/consul.d/default.json') do
      its(:content) { should match /server/ }
    end
  end

  describe 'sets up consul-template' do
    describe service('consul-template') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/consul-template.d/haproxy') do
      its(:content) { should match %r{source = "/etc/haproxy/consul.cfg"} }
      its(:content) { should match %r{destination = "/etc/haproxy/haproxy.cfg"} }
      its(:content) { should match %r{command = "systemctl restart haproxy.service"} }
    end
  end

  describe 'consul-template renders the template' do
    describe service('haproxy') do
      it { should be_enabled }
      it { should be_running }
    end

    describe file('/etc/haproxy/haproxy.cfg') do
      its(:content) { should match /peer consul-centos-70.*:1024/ }
      its(:content) { should match /server consul-centos-70.*:3306/ }
      its(:content) { should match /server consul-centos-70.*:8080/ }
    end

    describe command('haproxy -c -f /etc/haproxy/haproxy.cfg') do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match /valid/ }
      its(:stdout) { should_not match /warn/i }
    end

    describe port(80) do
      it { should be_listening }
    end

    describe port(1024) do
      it { should be_listening }
    end

    describe port(3306) do
      it { should be_listening }
    end
  end
end

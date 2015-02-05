require 'spec_helper'

describe 'haproxy-ng::default' do
  describe 'installs haproxy' do
    describe package('haproxy') do
      it { should be_installed }
    end
  end

  describe 'configures haproxy instance' do
    describe file('/etc/haproxy/haproxy.cfg') do
      [
        'global',
        'daemon',
        'user haproxy',
        'group haproxy',
        'pidfile /var/run/haproxy.pid',
        'maxconn 50000',
      ].each do |directive|
        its(:content) { should match %r{#{directive}} }
      end
    end

    describe command('haproxy -c -f /etc/haproxy/haproxy.cfg') do
      its(:stdout) { should_not match /warning/i }
      its(:stdout) { should match /valid/ }
    end
  end

  describe 'manages haproxy service' do
    describe service('haproxy') do
      it { should be_enabled }
      it { should be_running }
    end
  end

  describe 'configures individual proxies correctly' do
    %w(
      /etc/haproxy/haproxy.cfg
      /tmp/kitchen/cache/haproxy.defaults.HTTP.cfg
    ).each do |f|
      describe file(f) do
        [
          'defaults HTTP',
          'mode http',
          'maxconn 50000',
          'timeout connect 5s',
          'timeout client 50s',
          'timeout server 50s',
        ].each do |directive|
          its(:content) { should match %r{#{directive}} }
        end
      end
    end

    %w(
      /etc/haproxy/haproxy.cfg
      /tmp/kitchen/cache/haproxy.frontend.www.cfg
    ).each do |f|
      describe file(f) do
        [
          'frontend www',
          'bind \*:80',
          'default_backend app',
        ].each do |directive|
          its(:content) { should match %r{#{directive}} }
        end
      end
    end

    %w(
      /etc/haproxy/haproxy.cfg
      /tmp/kitchen/cache/haproxy.backend.app.cfg
      ).each do |f|
      describe file(f) do
        [
          'backend app',
          'option httpchk',
          'server app01 12.34.56.78:80 check inter 5000 rise 2 fall 5',
          'server app02 22.34.56.78:80 check inter 5000 rise 2 fall 5',
        ].each do |directive|
          its(:content) { should match Regexp.new(directive) }
        end
      end
    end
  end
end

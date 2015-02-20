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

  describe 'skips proxies when appropriate' do
    describe file('/etc/haproxy/haproxy.cfg') do
      its(:content) { should_not match /should_not_exist/ }
    end
  end

  describe 'configures peers correctly' do
    %w(
      /etc/haproxy/haproxy.cfg
      /tmp/kitchen/cache/haproxy.peers.lb.cfg
    ).each do |f|
      describe file(f) do
        [
          'peers lb',
          'peer lb01 12.4.56.78:1024',
          'peer lb02 12.34.56.8:1024'
        ].each do |directive|
          its(:content) { should match %r{#{directive}} }
        end
      end
    end
  end

  describe 'configures userlists correctly' do
    %w(
      /etc/haproxy/haproxy.cfg
      /tmp/kitchen/cache/haproxy.userlist.L1.cfg
    ).each do |f|
      describe file(f) do
        [
          'group G1 users tiger,scott',
          'group G2 users xdb,scott',
          'user tiger insecure-password password123',
          'user scott insecure-password pa55word123',
          'user xdb insecure-password hello'
        ].each do |directive|
          its(:content) { should match %r{#{directive}} }
        end
      end
    end
  end

  describe 'configures individual proxies correctly' do
    %w(
      /etc/haproxy/haproxy.cfg
      /tmp/kitchen/cache/haproxy.defaults.TCP.cfg
    ).each do |f|
      describe file(f) do
        [
          'balance leastconn',
          'mode tcp',
          'option clitcpka',
          'option srvtcpka',
          'timeout connect 5s',
          'timeout client 300s',
          'timeout server 300s',
          'source',
        ].each do |directive|
          its(:content) { should match %r{#{directive}} }
        end
      end
    end

    %w(
      /etc/haproxy/haproxy.cfg
      /tmp/kitchen/cache/haproxy.listen.mysql.cfg
    ).each do |f|
      describe file(f) do
        [
          'bind 0.0.0.0:3306',
          'balance leastconn',
          'mode tcp',
          'option mysql-check',
          'description mysql pool',
          'acl inside src 10.0.0.0/8',
          'source',
          'server mysql01 12.34.56.89:3306 maxconn 500 check port 3306 inter 2s backup',
          'server mysql02 12.34.56.90:3306 maxconn 500 check port 3306 inter 2s backup',
        ].each do |directive|
          its(:content) { should match %r{#{directive}} }
        end
      end
    end

    %w(
      /etc/haproxy/haproxy.cfg
      /tmp/kitchen/cache/haproxy.defaults.HTTP.cfg
    ).each do |f|
      describe file(f) do
        [
          'defaults HTTP',
          'mode http',
          'balance roundrobin',
          'maxconn 2000',
          'timeout connect 5s',
          'timeout client 50s',
          'timeout server 50s',
          'default_backend app',
          'source',
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
          'mode http',
          'option clitcpka',
          'description http frontend',
          'acl inside src 10.0.0.0/8',
          'default_backend app',
          'use_backend app if inside',
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
          'balance roundrobin',
          'mode http',
          'option httpchk',
          'description app pool',
          'acl inside src 10.0.0.0/8',
          'source',
          'server app01 12.34.56.78:80 check inter 5000 rise 2 fall 5',
          'server app02 22.34.56.78:80 check inter 5000 rise 2 fall 5',
        ].each do |directive|
          its(:content) { should match Regexp.new(directive) }
        end
      end
    end
  end
end

require 'spec_helper'

describe 'my-lb::default' do
  context 'When all attributes are default, on an unspecified platform' do

    let(:chef_run) do
      ChefSpec::ServerRunner.new.converge(described_recipe)
    end

    it 'creates haproxy_defaults TCP' do
      expect(chef_run).to create_haproxy_defaults 'TCP'
    end

    it 'creates haproxy_listen redis' do
      expect(chef_run).to create_haproxy_listen 'redis'
    end

    it 'creates haproxy_defaults HTTP' do
      expect(chef_run).to create_haproxy_defaults 'HTTP'
    end

    it 'creates haproxy_backend app' do
      expect(chef_run).to create_haproxy_backend 'app'
    end

    it 'skips haproxy_backend should_not_exist' do
      expect(chef_run).to_not create_haproxy_backend 'should_not_exist'
    end

    it 'creates haproxy_frontend www' do
      expect(chef_run).to create_haproxy_frontend 'www'
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end

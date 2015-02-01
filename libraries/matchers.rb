#
# Matchers for ChefSpec
#

if defined?(ChefSpec)
  def create_haproxy_instance(instance)
    ChefSpec::Matchers::ResourceMatcher.new(:haproxy_instance, :create, instance)
  end

  def delete_haproxy_instance(instance)
    ChefSpec::Matchers::ResourceMatcher.new(:haproxy_instance, :delete, instance)
  end

  def create_haproxy_proxy(proxy)
    ChefSpec::Matchers::ResourceMatcher.new(:haproxy_proxy, :create, proxy)
  end

  def delete_haproxy_proxy(proxy)
    ChefSpec::Matchers::ResourceMatcher.new(:haproxy_proxy, :delete, proxy)
  end
end

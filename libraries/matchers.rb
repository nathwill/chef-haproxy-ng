#
# Matchers for ChefSpec
#

if defined?(ChefSpec)
  %w(
    instance
    proxy
    peers
    userlist
    backend
    defaults
    frontend
    listen
  ).each do |r|
    %w( create delete ).each do |a|
      define_method("#{a}_haproxy_#{r}") do |n|
        ChefSpec::Matchers::ResourceMatcher.new(
          "haproxy_#{r}".to_sym,
          a.to_sym,
          n
        )
      end
    end
  end
end

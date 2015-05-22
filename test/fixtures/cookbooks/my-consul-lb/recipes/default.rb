
%w( consul haproxy consul_template ).each do |r|
  include_recipe "#{cookbook_name}::#{r}"
end

include_recipe "haproxy-ng::service"

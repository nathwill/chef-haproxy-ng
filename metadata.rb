name             'haproxy-ng'
maintainer       'Nathan Williams'
maintainer_email 'nath.e.will@gmail.com'
license          'apache2'
description      'Installs/Configures haproxy-ng'
long_description 'Installs/Configures haproxy-ng'
version          '0.1.2'
#source_url       'https://github.com/nathwill/chef-haproxy-ng'
#issues_url       'https://github.com/nathwill/chef-haproxy-ng/issues'

%w( redhat scientific centos fedora debian ubuntu ).each do |platform|
  supports platform
end

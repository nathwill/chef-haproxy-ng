name             'haproxy-ng'
maintainer       'Nathan Williams'
maintainer_email 'nath.e.will@gmail.com'
license          'apache2'
description      'Installs/Configures haproxy-ng'
long_description 'Installs/Configures haproxy-ng'
version          '0.2.0'

%w( redhat scientific centos fedora ubuntu ).each do |platform|
  supports platform
end

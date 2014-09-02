class xen::xentools(
  $ensure         = $xen::ensure,
  $package        = $xen::params::xentools_package,
  $install_method = $xen::params::xentools_install_method,
  $passwd         = '0',
  $boot           = '0',
  $pygrub         = '0',
  $lvm            = 'vg0',
  $bridge         = undef,
  $nameserver     = undef,
) inherits ::xen {

  package { $package:
    ensure => $ensure,
  }

  File {
    ensure  => $ensure,
    require => Package[$package],
  }

  file { '/etc/xen-tools/xm.tmpl':
    source => 'puppet:///modules/xen/xen-tools/xm.tmpl',
  }
  file { '/etc/xen-tools/role.d/puppet':
    content => template('xen/xen-tools/role.d/puppet.erb'),
    mode    => '755',
  }
  file { '/etc/xen-tools/role.d/ovh':
    content => template('xen/xen-tools/role.d/ovh.erb'),
    mode    => '755',
  }
  file { '/etc/xen-tools/partitions.d/partitions.example':
    source => 'puppet:///modules/xen/xen-tools/partitions.d/partitions.example',
  }
  file { '/etc/xen-tools/xen-tools.conf':
    content => template("xen/xen-tools/${::lsbdistcodename}/xen-tools.conf.erb"),
  }
}


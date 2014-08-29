class xen::xentools(
  $package    = $xen::params::xentools_package,
  $lvm        = 'vg0',
  $bridge     = undef,
  $nameserver = $xen::params::xentools_nameserver,
) {
  package { $package:
    ensure => installed,
  }

  File {
    require => Package[$package],
  }

  file { '/etc/xen-tools/xm.tmpl':
    ensure => present,
    source => 'puppet:///modules/xen/xen-tools/xm.tmpl',
  }
  file { '/etc/xen-tools/role.d/puppet':
    ensure  => present,
    content => template('xen/xen-tools/role.d/puppet.erb'),
    mode    => '755',
  }
  file { '/etc/xen-tools/role.d/ovh':
    ensure  => present,
    content => template('xen/xen-tools/role.d/ovh.erb'),
    mode    => '755',
  }
  file { '/etc/xen-tools/partitions.d/partitions.example':
    ensure => present,
    source => 'puppet:///modules/xen/xen-tools/partitions.d/partitions.example',
  }
  file { '/etc/xen-tools/xen-tools.conf':
    ensure  => present,
    content => template("xen/xen-tools/${::lsbdistcodename}/xen-tools.conf.erb"),
  }
}


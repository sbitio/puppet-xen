class xen::dom0(
  $ensure         = $xen::ensure,
  $package        = $xen::params::dom0_package,
  $service        = $xen::params::dom0_service,
  $extra_packages = $xen::params::dom0_extra_packages,
  $networking     = undef,
  $bridge         = undef,
  $vcpus          = 1,
  $mem            = '256',
  $suspend        = false,
) inherits ::xen {

  validate_array($extra_packages)
  validate_bool($suspend)

  if $networking {
    $networking_options = [ 'bridge', 'route' ]
    if ! ($networking in $networking_options) {
      fail("Invalid networking parameter. Valid values: ${networking_options}")
    }
  }

  package { $package:
    ensure => $ensure,
  }
  package { $extra_packages:
    ensure => $ensure,
  }

  $service_ensure = $ensure ? {
    present => running,
    absent  => stopped,
  }
  service { $service:
    ensure    => $service_ensure,
    require   => Package[$package],
    hasstatus => false,
  }

  file { '/etc/xen/xend-config.sxp':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => 440,
    content => template("xen/dom0/${::lsbdistcodename}/xend-config.sxp.erb"),
    require => Package[$package],
    notify  => Service[$service],
  }
  $xen_auto_ensure = $ensure ? {
    present => directory,
    absent  => absent,
  }
  file { '/etc/xen/auto':
    ensure => $xen_auto_ensure,
    require => Package[$package],
  }
  file { '/etc/default/xendomains':
    ensure  => $ensure,
    content => template("xen/dom0/${::lsbdistcodename}/xendomains.erb"),
    require => Package[$package],
  }
  $networking_ensure = $ensure ? {
    present => $networking,
    absent  => absent,
  }
  $networking_ensure_real = $networking_ensure ? {
    /route/ => present,
    default => absent,
  }
  file { '/etc/sysctl.d/xen-networking.conf':
    ensure  => $networking_ensure_real,
    content => "net.ipv4.ip_forward=1
net.ipv4.conf.default.proxy_arp=1
net.ipv6.conf.all.forwarding=1
",
  }

  # Grub.
  file_line { '/etc/default/grub':
    ensure => $ensure,
    path   => '/etc/default/grub',
    line   => "GRUB_CMDLINE_XEN_DEFAULT=\"dom0_mem=${mem}M,max:${mem}M dom0_max_vcpus=${vcpus} dom0_vcpus_pin\"",
    match  => '^GRUB_CMDLINE_XEN_DEFAULT',
    notify => Exec['update_grub'],
  }
  case $ensure {
    present: {
      exec { 'grub-priorities-xen':
        command => 'dpkg-divert --divert /etc/grub.d/08_linux_xen --rename /etc/grub.d/20_linux_xen',
        unless  => ['test -f /etc/grub.d/08_linux_xen'],
        notify  => Exec['update_grub'],
      }
    }
    absent: {
      exec { 'grub-priorities-xen':
        command => 'dpkg-divert --rename --remove /etc/grub.d/20_linux_xen',
        unless  => ['test -f /etc/grub.d/20_linux_xen'],
        notify  => Exec['update_grub'],
      }
    }
  }

  exec {'update_grub':
    refreshonly => true,
    command     => '/usr/sbin/update-grub',
  }

  # Defined domUs.
#  create_resources(
#    'xen::dom0::define_domu',
#    hiera_hash("xen::domu::config", {}),
#  )
}


class xen::dom0(
  $package        = $xen::params::dom0_package,
  $service        = $xen::params::dom0_service,
  $extra_packages = $xen::params::dom0_extra_packages,
  $networking     = undef,
  $vcpus          = 1,
  $mem            = '256',
  $suspend        = false,
) inherits xen::params {

  validate_array($extra_packages)
  validate_bool($suspend)

  $networking_options = [ undef, 'bridge', 'route' ]
  if ! ($networking in $networking_options) {
    fail("Invalid networking parameter. Valid values: ${networking_options}")
  }

  package { $package:
    ensure => present,
  }
  service { $service:
    ensure    => running,
    require   => Package[$package],
    hasstatus => false,
  }

  package { $extra_packages:
    ensure => present,
  }

  file { '/etc/xen/xend-config.sxp':
    owner   => 'root',
    group   => 'root',
    mode    => 440,
    content => template("xen/dom0/${::lsbdistcodename}/xend-config.sxp.erb"),
    require => Package[$package],
    notify  => Service[$service],
  }
  file { '/etc/xen/auto':
    ensure => directory,
    require => Package[$package],
  }
  file { '/etc/default/xendomains':
    content => template("xen/dom0/${::lsbdistcodename}/xendomains.erb"),
    require => Package[$package],
  }

  $networking_ensure = $networking ? {
    /route/ => present,
    default => absent,
  }
  file { '/etc/sysctl.d/xen-networking.conf':
    ensure  => $networking_ensure,
    content => "net.ipv4.ip_forward=1
net.ipv4.conf.default.proxy_arp=1
net.ipv6.conf.all.forwarding=1
",
  }

  # Grub.
  file_line { '/etc/default/grub':
    path   => '/etc/default/grub',
    line   => "GRUB_CMDLINE_XEN_DEFAULT=\"dom0_mem=${mem}M,max:${mem}M dom0_max_vcpus=${vcpus} dom0_vcpus_pin\"",
    match  => '^GRUB_CMDLINE_XEN_DEFAULT',
    notify => Exec['update_grub'],
  }
  exec { 'reorder-grub':
   command => '/bin/mv /etc/grub.d/10_linux /etc/grub.d/20_linux; /bin/mv /etc/grub.d/20_linux_xen /etc/grub.d/10_linux_xen',
   onlyif  => ['/usr/bin/test -f /etc/grub.d/10_linux', '/usr/bin/test -f /etc/grub.d/20_linux_xen'],
   notify  => Exec['update_grub'],
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


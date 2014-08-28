class xen::xenwatch(
  $package => $xen::params::xenwatch_package,
) {
  package { $package:
    ensure => present,
  }
}


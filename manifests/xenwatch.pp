# == Class: xen::xenwatch
#
# Installs xenwatch.
#
class xen::xenwatch(
  $ensure  = $xen::ensure,
  $package = $xen::params::xenwatch_package,
) inherits xen {
  package { $package:
    ensure => $ensure,
  }
}


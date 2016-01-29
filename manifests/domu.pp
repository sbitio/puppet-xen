# == Class: xen::domu
#
# Install Xen domU packages and configures the system.
#
# === Parameters
#
# [*ensure*]
#   Wheter to install or uninstall xen's dom0.
#
# [*kernel_package*]
#   Xen domU kernel package name.
#
# [*purge_package*]
#   List of packages to purge.
#
# Reference http://wiki.debian.org/PyGrub
#
class xen::domu (
  $ensure         = $xen::ensure,
  $kernel_package = $xen::params::domu_kernel_package,
  $purge_packages = $xen::params::domu_purge_packages,
) inherits xen {

  package {$kernel_package:
    ensure => present,
  }
  package { $purge_packages:
    ensure => purged,
  }

  # PyGrub.
  file {'/boot/grub':
    ensure => directory,
    mode   => '0444',
  }
  file {'/boot/grub/menu.lst':
    ensure  => present,
    content => template('xen/domu/grub/menu.lst'),
  }

}


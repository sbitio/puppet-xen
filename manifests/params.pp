# == Class: xen::params
#
# Default parameters.
#
class xen::params {

  case $::operatingsystem {
    'Debian': {
      # dom0
      case $::lsbdistcodename {
        'squeeze': {
          # xen hypervisor 4.0
          $dom0_package = "xen-linux-system-2.6-xen-${::architecture}"
          $dom0_service = 'xend'
        }
        'wheezy', 'jessie': {
          # wheezy: xen hypervisor 4.1
          # jessie: xen hypervisor 4.4
          $dom0_package = "xen-linux-system-${::architecture}"
          $dom0_service = 'xen'
        }
        default: {
          fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily Debian")
        }
      }
      $dom0_extra_packages = ['irqbalance',]

      # domU
      $domu_kernel_package = "linux-image-${::architecture}"
      $domu_purge_packages = ['grub-common',]

      # xen-tools
      $xentools_package        = 'xen-tools'
      $xentools_install_method = 'debootstrap'

      # Other utils
      #$xenstore_package    = 'xenstore-utils'
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily Debian")
    }
  }
}


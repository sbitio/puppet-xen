class xen::params {

  case $::operatingsystem {
    'Debian': {
      # dom0
      case $::lsbdistcodename {
        'squeeze': {
          # xen hypervisor 4.0
          $dom0_package = "xen-linux-system-2.6-xen-$::architecture"
          $dom0_service = 'xend'
        }
        'wheezy', 'jessie': {
          # wheezy: xen hypervisor 4.1
          # jessie: xen hypervisor 4.4
          $dom0_package = "xen-linux-system-$::architecture"
          $dom0_service = 'xen'
        }
      }
      $dom0_extra_packages = ['irqbalance',]

      # domU
      $domu_kernel_package = "linux-image-$::architecture"
      $domu_purge_packages = ['grub-common',]

      # Utils
      $xenstore_package    = 'xenstore-utils'
      $xentools_package    = 'xen-tools'
      $xentools_nameserver = undef
      $xenwatch_package    = 'xenwatch'
    }
    default: {
      fail("Unsupported operatingsystem: ${::operatingsystem}, module ${module_name} only supports Debian at present.")
    }
  }
}


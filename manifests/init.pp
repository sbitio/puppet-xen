# == Class: xen
#
# Base class.
#
# === Parameters
#
# [*ensure*]
#   Wheter to install or uninstall.
#
class xen(
  $ensure = present,
) inherits xen::params {
  $ensure_options = [ present, absent ]
  if ! ($ensure in $ensure_options) {
    fail("Invalid ensure parameter. Valid values: ${ensure_options}")
  }
}


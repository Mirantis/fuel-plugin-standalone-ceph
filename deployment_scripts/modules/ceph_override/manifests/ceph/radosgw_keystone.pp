# NOTE (dukov) Copied from osnailyfacter::ceph::radosgw_keystone
class ceph_override::ceph::radosgw_keystone {

  $storage_hash = hiera_hash('storage', {})

  if $storage_hash['objects_ceph'] {
    # NOTE(dukov) We need to use different vip for Rados gateway since it's detached from controller
    $network_metadata    = hiera_hash('network_metadata')
    $public_vip   = $network_metadata['vips']['public_rados_ep']['ipaddr']
    $region          = hiera('region', 'RegionOne')
    # NOTE(dukov) We need to use different vip for Rados gateway since it's detached from controller
    $management_vip = $network_metadata['vips']['rados_ep']['ipaddr']
    $public_ssl_hash = hiera_hash('public_ssl')
    $ssl_hash        = hiera_hash('use_ssl', {})

    $public_protocol   = get_ssl_property($ssl_hash, $public_ssl_hash, 'radosgw', 'public', 'protocol', 'http')

    if ( $public_ssl_hash['services'] and $public_ssl_hash['cert_source'] == 'self_signed' ) {
      $public_address_one    = get_ssl_property($ssl_hash, $public_ssl_hash, 'radosgw', 'public', 'hostname', [$public_vip])
      $public_address = "rgw.${public_address_one}"
    }

    elsif ( $public_ssl_hash['services'] and $public_ssl_hash['cert_source'] == 'user_uploaded' ) {
      $ceph_cash = hiera_hash('standalone-ceph')
      $public_address = $ceph_cash['dns_hostname']
    }

    else {
      $public_address    = get_ssl_property($ssl_hash, $public_ssl_hash, 'radosgw', 'public', 'hostname', [$public_vip])
    }

    $internal_protocol = get_ssl_property($ssl_hash, {}, 'radosgw', 'internal', 'protocol', 'http')
    $internal_address  = get_ssl_property($ssl_hash, {}, 'radosgw', 'internal', 'hostname', [$management_vip])

    $admin_protocol    = get_ssl_property($ssl_hash, {}, 'radosgw', 'admin', 'protocol', 'http')
    $admin_address     = get_ssl_property($ssl_hash, {}, 'radosgw', 'admin', 'hostname', [$management_vip])

    $public_url        = "${public_protocol}://${public_address}:8080/swift/v1"
    $internal_url      = "${internal_protocol}://${internal_address}:8080/swift/v1"
    $admin_url         = "${admin_protocol}://${admin_address}:8080/swift/v1"

    class {'::osnailyfacter::wait_for_keystone_backends': }

    keystone::resource::service_identity { 'radosgw':
      configure_user      => false,
      configure_user_role => false,
      service_type        => 'object-store',
      service_description => 'Openstack Object-Store Service',
      service_name        => 'swift',
      region              => $region,
      public_url          => $public_url,
      admin_url           => $admin_url,
      internal_url        => $internal_url,
    }

    Class['::osnailyfacter::wait_for_keystone_backends'] -> Keystone::Resource::Service_Identity['radosgw']
  }
}

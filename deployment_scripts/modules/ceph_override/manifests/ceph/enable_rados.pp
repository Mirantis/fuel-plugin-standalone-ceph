# NOTE (dukov) Copied from osnailyfacter::ceph::enable_rados
class ceph_override::ceph::enable_rados {

  notice('MODULAR: ceph/enable_rados.pp')

  # NOTE(dukov) We need to use different vip for Rados gateway since it's detached from controller
  $network_metadata = hiera_hash('network_metadata')
  $public_ip        = $network_metadata['vips']['public_rados_ep']['ipaddr']
  $management_vip   = $network_metadata['vips']['rados_ep']['ipaddr']
  $service_endpoint = hiera('service_endpoint', '')
  $ssl_hash         = hiera_hash('use_ssl', {})

  include ::ceph::params

  $radosgw_service       = $::ceph::params::service_radosgw
  $radosgw_override_file = '/etc/init/radosgw-all.override'

  if ($::operatingsystem == 'Ubuntu') {
    # ensure the service is stopped and will not start on boot
    service { 'radosgw':
      enable   => false,
      provider => 'debian',
    }

    service { 'radosgw-all':
      ensure   => running,
      enable   => true,
      provider => 'upstart',
    }

    file {$radosgw_override_file:
      ensure  => present,
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => "start on runlevel [2345]\nstop on starting rc RUNLEVEL=[016]\n",
    }

    Service['radosgw'] ->
    File[$radosgw_override_file] ~>
    Service['radosgw-all'] ->
    ::Osnailyfacter::Wait_for_backend['object-storage']
  }
  else {
    service { $radosgw_service:
      ensure => running,
      enable => true,
    }

    Service[$radosgw_service] -> ::Osnailyfacter::Wait_for_backend['object-storage']
  }

  $rgw_protocol = get_ssl_property($ssl_hash, {}, 'radosgw', 'internal', 'protocol', 'http')
  # NOTE(dukov) Removed service_endpoint
  $rgw_address  = get_ssl_property($ssl_hash, {}, 'radosgw', 'internal', 'hostname', [$management_vip])
  $rgw_url = "${rgw_protocol}://${rgw_address}:8080"

  $lb_hash = {
    'object-storage' => {
      name     => 'object-storage',
      provider => 'http',
      url      => $rgw_url
    }
  }

  ::osnailyfacter::wait_for_backend {'object-storage':
    lb_hash     => $lb_hash
  }
}

class standalone-ceph::hosts {

  notice('MODULAR: standalone_ceph/hosts.pp')

  $plugin_metadata  = hiera_hash('standalone-ceph')
  $dns_hostname     = $plugin_metadata['dns_hostname']

  $public_ssl_hash  = hiera_hash('public_ssl')
  $domain_name      = $public_ssl_hash['hostname']

  $network_metadata = hiera_hash('network_metadata')
  $public_vip       = $network_metadata['vips']['public_rados_ep']['ipaddr']

  if ($public_ssl_hash['services'] and $public_ssl_hash['cert_source'] == 'self_signed') {
    $host_name   = "rgw.${domain_name}"
    $host_ensure = 'present'
  }

  elsif ($public_ssl_hash['services'] and $public_ssl_hash['cert_source'] == 'user_uploaded') {
    $host_name   = $dns_hostname
    $host_ensure = 'present'
  }

  else {
    $host_name   = ["rgw.${domain_name}", $dns_hostname]
    $host_ensure = 'absent'
  }

  host { $host_name:
    ensure => $host_ensure,
    ip     => $public_vip,
  }
}

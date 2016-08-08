notice('MODULAR: standalone-ceph/ceph-mon-firewall.pp')

$network_scheme     = hiera_hash('network_scheme', {})
$management_nets    = get_routable_networks_for_network_role($network_scheme, 'rados_gw_management_vip')

$haproxy_stats_port = 10000

$swift_account_port           = 6002
$swift_container_port         = 6001
$swift_object_port            = 6000
$swift_proxy_check_port       = 49001
$swift_proxy_port             = 8080

$corosync_input_port          = 5404
$corosync_networks = get_routable_networks_for_network_role($network_scheme, 'mgmt/corosync')
$corosync_output_port         = 5405
$pcsd_port                    = 2224

openstack::firewall::multi_net {'300 haproxy stats tcp':
  port        => $haproxy_stats_port,
  proto       => 'tcp',
  action      => 'accept',
  source_nets => $management_nets,
}

firewall {'030 allow connections from haproxy namespace':
  source => '240.0.0.2',
  action => 'accept',
}

firewall {'103 swift':
  port   => [$swift_proxy_port, $swift_object_port, $swift_container_port, $swift_account_port, $swift_proxy_check_port],
  proto  => 'tcp',
  action => 'accept',
}

openstack::firewall::multi_net {'113 corosync-input':
  port        => $corosync_input_port,
  proto       => 'udp',
  action      => 'accept',
  source_nets => $corosync_networks,
}

openstack::firewall::multi_net {'114 corosync-output':
  port        => $corosync_output_port,
  proto       => 'udp',
  action      => 'accept',
  source_nets => $corosync_networks,
}

openstack::firewall::multi_net {'115 pcsd-server':
  port        => $pcsd_port,
  proto       => 'tcp',
  action      => 'accept',
  source_nets => $corosync_networks,
}

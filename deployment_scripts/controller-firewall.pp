notice('MODULAR: standalone-ceph/controller-firewall.pp')

$network_scheme     = hiera_hash('network_scheme', {})
$management_nets    = get_routable_networks_for_network_role($network_scheme, 'mgmt/vip')
$haproxy_stats_port = 10000

openstack::firewall::multi_net {'300 haproxy stats tcp':
  port        => $haproxy_stats_port,
  proto       => 'tcp',
  action      => 'accept',
  source_nets => $management_nets,
}

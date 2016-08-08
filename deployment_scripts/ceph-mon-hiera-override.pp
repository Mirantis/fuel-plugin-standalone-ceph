notice('MODULAR: standalone-ceph/ceph-mon-hiera-override.pp')

$plugin_name      = 'standalone-ceph'
$plugin_metadata  = hiera($plugin_name, false)
$hiera_dir        = '/etc/hiera/plugins'
$plugin_yaml      = "${plugin_name}.yaml"

$role            = 'ceph-mon'
$primary_role    = 'primary-ceph-mon'
$plugin_roles     = [$primary_role, $role]
$controller_roles = ['primary-controller', 'controller']

# Set it to false to work around hardcoded vip names
$colocate_haproxy = false

$current_roles    = hiera('roles')

$network_metadata 	     	  = hiera_hash('network_metadata')
$ceph_primary_monitor_node 	  = get_nodes_hash_by_roles($network_metadata, [$primary_role])
$ceph_monitor_nodes 		  = get_nodes_hash_by_roles($network_metadata, $plugin_roles)

if !empty(intersection($current_roles, $plugin_roles)) {
  $corosync_roles = $plugin_roles
}

file { '/etc/hiera':
  ensure  => directory,
}

file { $hiera_dir:
  ensure   => directory,
  require  => File['/etc/hiera'],
}

file { "${hiera_dir}/${plugin_yaml}":
  ensure   => file,
  content  => template("${plugin_name}/${plugin_yaml}.erb"),
  require  => File[$hiera_dir],
}

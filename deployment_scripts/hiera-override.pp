$plugin_name            = "standalone-ceph"
notice("MODULAR: ${plugin_name}/hiera-override.pp")

$plugin_metadata 	= hiera($plugin_name, false)
$hiera_dir              = '/etc/hiera/override'
$plugin_yaml            = "${plugin_name}.yaml"

if $plugin_metadata {
  $network_metadata 	     	= hiera_hash('network_metadata')
  $ceph_primary_monitor_node 	= get_nodes_hash_by_roles($network_metadata, ['primary-standalone-ceph-mon'])
  $ceph_monitor_nodes 		= get_nodes_hash_by_roles($network_metadata, ['primary-standalone-ceph-mon','standalone-ceph-mon'])


  file { '/etc/hiera/override':
    ensure  => directory,
  }

  file { "${hiera_dir}/${plugin_yaml}":
    ensure  => file,
    content => template("${plugin_name}/${plugin_yaml}.erb"),
  }

  file_line {"${plugin_name}_hiera_override":
    path  => '/etc/hiera.yaml',
    line  => "  - override/${plugin_name}",
    after => '  - override/module/%{calling_module}',
  }
}

notice('MODULAR: standalone-ceph/ceph_client.pp')

$ceph_primary_monitor_node = hiera('ceph_primary_monitor_node')
$primary_mons              = keys($ceph_primary_monitor_node)
$primary_mon               = $ceph_primary_monitor_node[$primary_mons[0]]['name']

include ceph::ssh
include ceph::params

Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
       cwd  => '/root',
}

package { $::ceph::params::package_radosgw:
  ensure => present,
}

exec {'ceph-deploy config pull':
  command   => "ceph-deploy --overwrite-conf config pull ${primary_mon}",
  cwd       => '/etc/ceph',
  creates   => '/etc/ceph/ceph.conf',
  tries     => 5,
  try_sleep => 2,
}

file {'/root/ceph.conf':
  ensure => link,
  target => '/etc/ceph/ceph.conf',
}

exec {'ceph-deploy gatherkeys remote':
  command   => "ceph-deploy gatherkeys ${primary_mon}",
  creates   => ['/root/ceph.bootstrap-mds.keyring',
                '/root/ceph.bootstrap-osd.keyring',
                '/root/ceph.client.admin.keyring',
                '/root/ceph.mon.keyring',],
  tries     => 5,
  try_sleep => 2,
}

file {'/etc/ceph/ceph.client.admin.keyring':
  ensure => file,
  source => '/root/ceph.client.admin.keyring',
  mode   => '0600',
  owner  => 'root',
  group  => 'root',
}

Class['ceph::params'] ->
  Exec['ceph-deploy config pull'] ->
    File['/root/ceph.conf'] ->
      Exec['ceph-deploy gatherkeys remote'] ->
        File['/etc/ceph/ceph.client.admin.keyring']

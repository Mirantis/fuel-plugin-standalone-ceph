# create new conf on primary Ceph MON, pull conf on all other nodes
class ceph_override::conf (
  $mon_addr                           = $::ceph::mon_addr,
  $node_hostname                      = $::ceph::node_hostname,
  $primary_mon                        = $::ceph::primary_mon,
  $auth_supported                     = $::ceph::auth_supported,
  $osd_journal_size                   = $::ceph::osd_journal_size,
  $osd_mkfs_type                      = $::ceph::osd_mkfs_type,
  $osd_pool_default_size              = $::ceph::osd_pool_default_size,
  $osd_pool_default_min_size          = $::ceph::osd_pool_default_min_size,
  $osd_pool_default_pg_num            = $::ceph::osd_pool_default_pg_num,
  $osd_pool_default_pgp_num           = $::ceph::osd_pool_default_pgp_num,
  $cluster_network                    = $::ceph::cluster_network,
  $public_network                     = $::ceph::public_network,
  $use_syslog                         = $::ceph::use_syslog,
  $syslog_log_level                   = $::ceph::syslog_log_level,
  $syslog_log_facility                = $::ceph::syslog_log_facility,
  $osd_max_backfills                  = $::ceph::osd_max_backfills,
  $osd_recovery_max_active            = $::ceph::osd_recovery_max_active,
  $rbd_cache                          = $::ceph::rbd_cache,
  $rbd_cache_writethrough_until_flush = $::ceph::rbd_cache_writethrough_until_flush,
) {
  if $node_hostname == $primary_mon {

    exec {'ceph-deploy new':
      command   => "ceph-deploy new ${node_hostname}:${mon_addr}",
      cwd       => '/etc/ceph',
      logoutput => true,
      creates   => '/etc/ceph/ceph.conf',
    }

    # link is necessary to work around http://tracker.ceph.com/issues/6281
    file {'/root/ceph.conf':
      ensure => link,
      target => '/etc/ceph/ceph.conf',
    }

    file {'/root/ceph.mon.keyring':
      ensure => link,
      target => '/etc/ceph/ceph.mon.keyring',
    }

    ceph_conf {
      'global/auth_supported':                     value => $auth_supported;
      'global/osd_journal_size':                   value => $osd_journal_size;
      'global/osd_mkfs_type':                      value => $osd_mkfs_type;
      'global/osd_pool_default_size':              value => $osd_pool_default_size;
      'global/osd_pool_default_min_size':          value => $osd_pool_default_min_size;
      'global/osd_pool_default_pg_num':            value => $osd_pool_default_pg_num;
      'global/osd_pool_default_pgp_num':           value => $osd_pool_default_pgp_num;
      'global/cluster_network':                    value => $cluster_network;
      'global/public_network':                     value => $public_network;
      'global/log_to_syslog':                      value => $use_syslog;
      'global/log_to_syslog_level':                value => $syslog_log_level;
      'global/log_to_syslog_facility':             value => $syslog_log_facility;
      'global/osd_max_backfills':                  value => $osd_max_backfills;
      'global/osd_recovery_max_active':            value => $osd_recovery_max_active;
      'client/rbd_cache':                          value => $rbd_cache;
      'client/rbd_cache_writethrough_until_flush': value => $rbd_cache_writethrough_until_flush;
    }

    Exec['ceph-deploy new'] ->
    File['/root/ceph.conf'] -> File['/root/ceph.mon.keyring'] ->
    Ceph_conf <||>

  } else {

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

    exec {'ceph-deploy init config':
      command => "ceph-deploy --overwrite-conf config push ${::hostname}",
      creates => '/etc/ceph/ceph.conf',
    }

    ceph_conf {
      'global/cluster_network': value => $cluster_network;
      'global/public_network':  value => $public_network;
    }

    Exec['ceph-deploy config pull'] ->
      Ceph_conf[['global/cluster_network', 'global/public_network']] ->
        File['/root/ceph.conf'] ->
          Exec['ceph-deploy gatherkeys remote'] ->
            File['/etc/ceph/ceph.client.admin.keyring'] ->
              Exec['ceph-deploy init config']
  }
}

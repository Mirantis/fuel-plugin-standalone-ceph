notice('MODULAR: standalone-ceph/rados-pki.pp')

include ::ceph::params
$rgw_nss_db_path = '/etc/ceph/nss'
$rgw_id          = 'radosgw.gateway'
$rgw_user    = $::ceph::params::user_httpd

Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
  cwd  => '/root',
}


ceph_conf {
  "client.${rgw_id}/nss db path": value => $rgw_nss_db_path;
}

# This creates the signing certs used by radosgw to check cert revocation
#   status from keystone
exec {'create nss db signing certs':
  command => "openssl x509 -in /var/lib/astute/keystone/ssl/certs/ca.pem -pubkey | \
    certutil -d ${rgw_nss_db_path} -A -n ca -t 'TCu,Cu,Tuw' && \
    openssl x509 -in /var/lib/astute/keystone/ssl/certs/signing_cert.pem -pubkey | \
    certutil -A -d ${rgw_nss_db_path} -n signing_cert -t 'P,P,P'",
} ->
exec {"chown -R ${rgw_user} ${rgw_nss_db_path}":}


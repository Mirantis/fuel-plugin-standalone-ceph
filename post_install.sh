#!/bin/bash


if ! fuel rel | grep -q 'Standalone Ceph'; then
  RELEASE=`fuel rel | grep Ubuntu | grep -v UCA | awk '{print $1}'`
  TOKEN=`fuel token`
  
  curl -H "X-Auth-Token: ${TOKEN}" http://localhost:8000/api/v1/releases/ -X POST -d @/var/www/nailgun/plugins/standalone-ceph-2.0/ceph_release.json

  fuel rel --sync-deployment-tasks --dir /etc/puppet/
fi

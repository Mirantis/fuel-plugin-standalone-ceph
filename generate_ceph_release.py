import yaml
import json
import sys


def merge(a, b):
    path = []
    for key in b:
        if key in a:
            if isinstance(a[key], dict) and isinstance(b[key], dict):
                merge(a[key], b[key], path + [str(key)])
            elif a[key] == b[key]:
                pass # same leaf value
            else:
                a[key] = b[key]
        else:
            a[key] = b[key]
    return a


openstackyaml = sys.argv[1];

with open(openstackyaml, 'r') as f:
    data = yaml.load(f)

base_r = dict(r[0]['fields']) # Base release
ubuntu_r = dict(r[2]['fields']) # mitaka-9.0 ubuntu release

rel = merge(base_r, ubuntu_r)
rel['roles_metadata']['controller']['limits']['min'] = 0
rel['name'] = 'Mitaka with Standalone Ceph on Ubuntu 14.04'
rel['description'] = 'This option will install the OpenStack Mitaka packages using Ubuntu as a base operating system. There is alson an option to deploy Ceph cluster only. With high availability features built in, you are getting a robust, enterprise-grade OpenStack deployment.'

with open('ceph_release.json', 'w+') as f:
    f.write(json.dumps(a))

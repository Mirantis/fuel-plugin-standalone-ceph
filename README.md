standalone-ceph
============

Plugin description

# Features

# TODO

  * Isolation between plugins - copy each task to separate one
  * Rados Gateway separation
  * UI restriction (don't allow standalone-ceph-mon, standalone-ceph-radosgw and controller) FIXME(pchechetin): Need more info about this case
  * Documentaion

# Test scenarious
  
  * Plugin enabled
    - Expected behavior: Ceph Mon role is deployed on separate node. Controller node doesn't have Ceph Mon process running.
    * RadosGW enabled
     - Expected behavior:
    * RadosGW disabled
     - Expected behavior:

  * Plugin disabled
    - Expected behavior: Ceph Mon role is deployed on Controller node and has Ceph Mon process running.

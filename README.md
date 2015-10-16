standalone-ceph
============

In pure Fuel, Ceph Monitor is deployed on each controller.
This plugin detaches Ceph Monitor from controller and creates new role called standalone-ceph-mon.

# Features

  * Isolation between plugins (The plugin doesn't interfere with other plugins, and depends on only Fuel inself.

# TODO

  * Rados Gateway separation

# Test scenarious
  
  * Plugin enabled
    - Expected behavior: Ceph Monitor role is deployed on a separate node. Controller node doesn't have Ceph Monintor process running.
    * RadosGW enabled
     - Expected behavior:
    * RadosGW disabled
     - Expected behavior:

  * Plugin disabled
    - Expected behavior: Ceph Monintor role is deployed on Controller node and has Ceph Monitor process running.

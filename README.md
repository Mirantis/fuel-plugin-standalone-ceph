standalone-ceph
============

In pure Fuel, Ceph Monitor is deployed on each controller.
This plugin detaches Ceph Monitor and Rados Gateway from controller and creates new role called standalone-ceph-mon.

# Features

  * Isolation between plugins (The plugin doesn't interfere with other plugins, and depends on only Fuel inself.
  * Plugin suports PKI and PKIZ token format and cant interract with fuel-plugin-token-provider

# Test scenarious

  * Plugin enabled
    - Expected behavior: Ceph Monitor role is deployed on a separate node. Controller node doesn't have Ceph Monintor and RadosGW process running.

  * Plugin disabled
    - Expected behavior: Ceph Monintor role is deployed on Controller node and has Ceph Monitor and RdosGW process running.

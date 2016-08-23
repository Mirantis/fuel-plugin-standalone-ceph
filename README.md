standalone-ceph
============

In pure Fuel, Ceph Monitor is deployed on each controller.
This plugin detaches Ceph Monitor and Rados Gateway from controller and creates new role called standalone-ceph-mon.
This plugin has been tested on Fuel 9.0.

# Features

  * Isolation between plugins (The plugin doesn't interfere with other plugins, and depends on only Fuel inself.
  * Plugin creates a new release in Fuel, in which it is possible to deploy Ceph cluster without Controller nodes.

# Test scenarious

  * Plugin enabled
    - Expected behavior: Ceph Monitor role is deployed on a separate node. Controller node doesn't have Ceph Monintor and RadosGW process running.

  * Plugin disabled
    - Expected behavior: Ceph Monintor role is deployed on Controller node and has Ceph Monitor and RdosGW process running.

# Developer notes
  * This plugin creates a new release via HTTP request to Nailgun API. To create the release, the post-install script uses a pre-created JSON that contains release's description and definition. This JSON (ceph_release.json) has been manually generated using the generate_ceph_release.py Python script. When porting to the newer version of Fuel, re-run this script to ensure that JSON is compatible with new Nailgun/Fuel version.

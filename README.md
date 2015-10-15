standalone-ceph
============

Plugin description

# Test scenarious
  
  * Plugin enabled
    - Expected behavior: Ceph Mon role is deployed on separate node. Controller node doesn't have Ceph Mon process running.
    * RadosGW enabled
     - Expected behavior:
    * RadosGW disabled
     - Expected behavior:

  * Plugin disabled
    - Expected behavior: Ceph Mon role is deployed on Controller node and has Ceph Mon process running.

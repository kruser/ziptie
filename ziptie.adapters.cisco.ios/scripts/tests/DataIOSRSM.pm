package DataIOSRSM;

use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw($rsm_vlans);

our $rsm_vlans = <<'END';
sh vlan

Virtual LAN ID:  1 (IEEE 802.1Q Encapsulation)

   vLAN Trunk Interface:   Port-channel1

   Protocols Configured:   Address:              Received:        Transmitted:

Virtual LAN ID:  28 (IEEE 802.1Q Encapsulation)

   vLAN Trunk Interface:   Port-channel1.28

 This is configured as native Vlan for the following interface(s) :
Port-channel1

   Protocols Configured:   Address:              Received:        Transmitted:
           IP              192.168.70.1                 0                   0

Virtual LAN ID:  31 (IEEE 802.1Q Encapsulation)

   vLAN Trunk Interface:   Port-channel1.31

   Protocols Configured:   Address:              Received:        Transmitted:
           IP              192.168.31.1                 0                   0

Virtual LAN ID:  32 (IEEE 802.1Q Encapsulation)

   vLAN Trunk Interface:   Port-channel1.32

   Protocols Configured:   Address:              Received:        Transmitted:
           IP              192.168.32.1                 0                   0

Virtual LAN ID:  33 (IEEE 802.1Q Encapsulation)

   vLAN Trunk Interface:   Port-channel1.33

   Protocols Configured:   Address:              Received:        Transmitted:
           IP              192.168.33.1                 0                   0

Virtual LAN ID:  55 (Inter Switch Link Encapsulation)

   vLAN Trunk Interface:   Port-channel2.55

   Protocols Configured:   Address:              Received:        Transmitted:
           IP              200.200.200.1                0                   0

cat-4000-ios#
END

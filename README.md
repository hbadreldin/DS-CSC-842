# DS-CSC-842 Cycle05: The Network Bot v1.0
# iplocator.pl, ipwatch.pl, macwatch.pl

# Purpose:
I have crated 2 scripts, ipwatch.pl is used if you want to be notified when specific IP address shows up on the network, and macwatch.pl is used to notify the administrators if specific MAC address is present on the network. Both scripts use the iplocator.pl script to locates the physical interface where an IP/MAC address is found and reports various useful information such as VLAN ID, network name, switch name, and the interface number & description. The scripts crawl the network findings pieces of information and use it as input to get more additional until it gets to the specific switch interface and displays the location. Both scripts will send an email message to the specified emails address in the script vairbales. 

# System Requirements: 
- Linux/Unix environment with Perl >= 5.14.2
- Scripts must be set to execute (chmod +x `<SCRIPT>`)

# Network Requirements:
- Scripts can execute remote commands on Cisco switches & routers that are running Cisco IOS 12.x or 15.x
- Scripts should have access to DHCP logs
- The iplocator.pl script requires a valid username and password with SSH access to all switches and routers. The access must be READ-ONLY
- The Linux server where the tool will run must be permitted on the firewalls for port 22 toward all network gear and log servers

# How it works: 
Watch for IP address: 
./ipwatch.pl `<IP address in decimal format>&` 

Watch for MAC address: 
./macwatch.pl `<MAC address in colon format>&`

# License:

This application is covered by the Creative Commons BY-SA license.

    https://creativecommons.org/licenses/by-sa/4.0
    https://creativecommons.org/licenses/by-sa/4.0/legalcode

EOF



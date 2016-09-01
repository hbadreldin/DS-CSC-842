# DS-CSC-842 Cycle02: The IP locator - iplocator.pl

# Purpose:
This script locates the physical interface where an IP address is transmitting and reports various useful information such as VLAN ID, network name, switch name, and the interface number & description. The scripts crawl the network findings pieces of information and use it as input to get more additional until it gets to the specific switch interface and displays the location. 

# System Requirements: 
- Linux/Unix environment with Perl >= 5.14.2
- Script must be set to execute (chmod +x iplocator.pl)

# Network Requirements:
- This script can execute remote commands on Cisco switches & routers that are running Cisco IOS 12.x or 15.x
- The script requires a valid username and password with SSH access to all switches. The access must be READ-ONLY

# How it works: 
./iplocator.pl `<IPv4 address>`

# Sample output:
<pre>
#################################################################
##	The IP locator v1.0 - IP address <> Physical location in LAN 
##				        Query for 10.14.129.67 
##		      Query Date & Time: 09/16/2016 11:23:14 
################################################################# 
>> Router:austrtr01 Router 		IP:172.16.127.2 
>> ----------------------------------------------------------------- 
>> Switch:austswtsh37 Switch 	IP:172.16.10.50 
>> ----------------------------------------------------------------- 
>> VLAN: Austin-West-Contract 	VLAN#:771 
>> ----------------------------------------------------------------- 
>> MAC:00:A0:F8:D1:59:FB 		Age#:4 minutess 
>> ----------------------------------------------------------------- 
>> Interface:Gi1/0/27 Desc#:Cube6 Status:Online 
>> -------------------------End of Report--------------------------- 
</pre>

# License:

This application is covered by the Creative Commons BY-SA license.

    https://creativecommons.org/licenses/by-sa/4.0/
    https://creativecommons.org/licenses/by-sa/4.0/legalcode

EOF



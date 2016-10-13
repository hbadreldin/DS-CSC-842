# DS-CSC-842 Cycle08: The NoFlap Checker v1.0
# noflap.pl

# Purpose:
Monitoring a global network is very difficult task to do without having the proper tools in place. Most of the time getting good tools will cost you very high amount of investment for initial deployment, and the reoccurring cost will also be high (if you go first grade tools). I have created this script to monitor our routing protocols in our internal and external networks. This script is very basic and it does provide passive monitoring capabilities for our EIGRP (Internal) and BGP (External) peering status. It will send an email if it sees routing protocol relationships go down or reestablish. The email will be sent to the NOC and they can escalate and take the proper actions. Being proactive is the main drive behind this tool.    

# System Requirements: 
- Linux with Perl >= 5.14.2
- Scripts set with +x (chmod +x `<SCRIPT>`)
- Log files set to +RO for the specific user running the scripts 

# Network Requirements:
- Network switches, routers and firewalls to send logs to a log server
- Logging should be enabled in the BGP process
    - bgp log-neighbor-changes 

# How it works: 
- crontab –e 
Then add the following and save: */5 * * * * `<path to the script>` >> /dev/null 2>&1
   # OR
- vi/etc/cron.d
Then add the following and save: */5 * * * * `<path to the script>` >> /dev/null 2>&1

Example:
*/5 * * * * /home/user/nms/noflap.pl >> /dev/null 2>&1

# Sample log Data:
- EIGRP: 
`Oct 16 08:58:09.352 EST: %DUAL-5-NBRCHANGE: EIGRP-IPv4 1: Neighbor 172.20.13.97 (Tunnel31) is up: new adjacency
Oct 16 08:59:47.361 EST: %DUAL-5-NBRCHANGE: EIGRP-IPv4 1: Neighbor 172.20.13.97 (Tunnel31) is down: Interface PEER-TERMINATION received
Oct 16 08:59:51.217 EST: %DUAL-5-NBRCHANGE: EIGRP-IPv4 1: Neighbor 172.20.13.97 (Tunnel31) is up: new adjacency
Oct 16 09:01:27.230 EST: %DUAL-5-NBRCHANGE: EIGRP-IPv4 1: Neighbor 172.20.13.97 (Tunnel31) is down: Interface PEER-TERMINATION received`

- BGP: 
`Dec 12 12:18:43.229 EST: %BGP-5-ADJCHANGE: Neighbor 205.116.72.3 Down BGP protocol initialization
Dec 12 12:18:51.981 EST: %BGP-5-ADJCHANGE: Neighbor 205.116.72.3 Up
Dec 12 12:21:54.183 EST: %BGP-5-ADJCHANGE: Neighbor 205.116.72.3 Down BGP protocol initialization`


# License:

This application is covered by the Creative Commons BY-SA license.

    https://creativecommons.org/licenses/by-sa/4.0
    https://creativecommons.org/licenses/by-sa/4.0/legalcode

EOF



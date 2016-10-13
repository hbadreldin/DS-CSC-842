# DS-CSC-842 Cycle08: The NoFlap Checker v1.0
# noflap.pl

# Purpose:
Monitoring a global network is very difficult task to do without having the proper tools in place. Most of the time getting good tools will cost you very high amount of investment for initial deployment, and the reoccurring cost will also be high (if you go first grade tools). I have created this script to monitor our routing protocols in our internal and external networks. This script is very basic and it does provide passive monitoring capabilities for our EIGRP (Internal) and BGP (External) peering status. It will send an email if it sees routing protocol relationships go down or reestablish. The email will be sent to the NOC and they can escalate and take the proper actions. Being proactive is the main drive behind this tool.    

# System Requirements: 
- Linux with Perl >= 5.14.2
- Scripts set with +x (chmod +x `<SCRIPT>`)
- Log files set to +RO for the specific user running the scripts 

Network:


# Network Requirements:
- Network switches, routers and firewalls to send logs to a log server
- Logging should be enabled in the BGP process
    - bgp log-neighbor-changes 

# How it works: 
Syntax:
crontab –e 
Then add the following and save: */5 * * * * `<path to the script>` >> /dev/null 2>&1
   OR
vi/etc/cron.d
Then add the following and save: */5 * * * * `<path to the script>` >> /dev/null 2>&1

Example:
*/5 * * * * /home/user/nms/noflap.pl >> /dev/null 2>&1


# License:

This application is covered by the Creative Commons BY-SA license.

    https://creativecommons.org/licenses/by-sa/4.0
    https://creativecommons.org/licenses/by-sa/4.0/legalcode

EOF



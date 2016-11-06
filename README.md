# DS-CSC-842 Cycle11: The Network Finder v1.0
# noflap.pl

# Purpose:
Single interface to run my previous cycels tools.    

# System Requirements: 
- Must have CGI module installed
- Apache >= 2.4.6
- CGI/Perl scripts located in: /var/www/cgi-bin/
- HTML webpage located in: /var/www/html/
- Scripts set with +x (chmod +x `<SCRIPT>`)

# Network Requirements:
- Cisco gear, if you want to locate the device – iplocator.pl 
- Valid credentials to Cisco gear as well as log servers – RO
- Better to run the tool on the log server itself
- Firewall open SSH from host to network gear & log servers

# How it works: 
- http://webserver/ipfinder.html 
- Scripts executed and results returned 
-- to the webpage for iplocator
-- to the helpdesk system for IP and MAC watch

Example:
- http:/192.168.0.18/ipfinder.html

# License:

This application is covered by the Creative Commons BY-SA license.

    https://creativecommons.org/licenses/by-sa/4.0
    https://creativecommons.org/licenses/by-sa/4.0/legalcode

EOF



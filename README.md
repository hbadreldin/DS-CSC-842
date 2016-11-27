# DS-CSC-842 Cycle14: Firewall ACL Auditor
# ACLAuditor.pl

# Purpose:
This tool runs against a saved/backed up firewall configuration.
It generates a list of the objects that have been created, but not referenced in any active ACL.   

# System Requirements: 
- Linux with Perl >= 5.14.2
- Valid firewall configuration files
- Scripts set with +x (chmod +x `<SCRIPT>`)

# How it works: 
- Edit the script to define the configuration file
- Run the script: perl ACLAuditor.pl

# References:
http://nwnsecurity.blogspot.com/2011/01/auditing-access-control-lists.html
https://0wned.it/tags/acl/
http://aharp.ittns.northwestern.edu/software/

EOF



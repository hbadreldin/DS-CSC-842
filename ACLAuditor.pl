#!/usr/bin/perl -w
###################################################################################
# ACLAuditor.pl: Audit firewall objects and determine which ones can be removed   #
#					It looks up objects that are not being called inside any ACL. #
###################################################################################
use strict;
use warnings;

# All variables
my @config = ();
my @namedObjects = ();
my @ToBeChecked = ();
my $namedObject;
my $counts;
my $ToBeChecked;
my $currentDate = `date +%Y%m%d`;
my $configFile = "/root/backups/ASA/ASA.bkup.$currentDate";

# Open the config file and load the findings
open FWconfig, $configFile or die "Could not open $configFile: $!"; 
	@config = <FWconfig>;
close FWconfig;

# Removing any trailing string
chomp @config;

# Extract named objects  & object-groups from config
@namedObjects = map { /^(object|object-group) (network|service) ([A-Za-z0-9-_]+)$/ ? $3 : () } @config;
$counts = scalar(@namedObjects);
print "***** This firewall is configured with total of $counts Objects & Object-groups. \n";

# Cleaning config and keeping only other config lines NOT having "object" or "object-group" in them
@config = grep { $_ !~ /^(object|object-group) / } @config;

# Returns unused objects  & object-groups that to be reviwed by firewall admin
print "***** Validating all configured firewall rules .... Done. \n";
foreach $namedObject (@namedObjects) {
		if (!grep { $_ =~ /$namedObject/ } @config) {
			push @ToBeChecked, $namedObject;
			$ToBeChecked = scalar(@ToBeChecked);
		}
}
if (@ToBeChecked) {
	print "***** The following $ToBeChecked Objects & Object-groups not being referenced anywhere. \n";
	print join("\n",@ToBeChecked),"\n";
}
else {
	print "****** This firewall is very well configured :)!! \n";
}


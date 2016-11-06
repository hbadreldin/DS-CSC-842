#!/bin/perl -w

###########################################################################################
# ipwatch.pl: This Perl script actively watches IP address presence in DHCP logs
# Usecase: This script can be used by Network & Security administrators to monitor network 
# 			nodes via IP address and send an email message to specific emails address, 
#			such as police office or NOC. This tool uses my iplocator.pl tool from the previous cycle
# Author: 	Hosam M. Badreldin
# Date:		17 September 2016
###########################################################################################
use warnings;
use strict;
use CGI;
use CGI::Carp; # send errors to the browser, not to the logfile

# All variables
my $currentDate = `date +%Y%m%d`;
my $logFile = "/var/logs/dhcp/DHCPD.log.$currentDate"; #must be changed
my $ipaddress = $ARGV[0];
my $matches = 0;
my @dhcp = ();

my $cgi = CGI->new;
my $IPAddress = $cgi->param('IPAddress');
print $cgi->header('text/plain');

print "Script lunched sucessfuly!!\n";
print "Watching for $IPAddress ... You will recive an email once found!\n";

########### tail -f the DHCP logs #####################
open my $tailf, "tail -f $logFile |" or die;
while (<$tailf>) {
    chomp;
    my $line = $_;
    if($line =~ m/ on $ipaddress/)
    {
        if (scalar(@dhcp) <= 2){
            push(@dhcp, "$line\n");
			$matches = 1;
        }        
        else {
            last;
        }
    }
}
close $tailf;

# send mail variables
my $sendmail = "/usr/lib/sendmail -oi -t -obq -f SOC\@company.com\n"; # must be changed
my $subject  = "Subject: *** IP watch result(s) for [$ipaddress] ****\n";
my $to       = "To: abuse\@company.com\n"; #must be changed
my $from     = "From: SOC\@company.com\n"; #Must be changed
my $content  = "";
my $counter  = 0;

###### running iplocator.pl & sending the email ######
if($matches == 1){
	@ipinfo = `../iplocator.pl $ipaddress`;
	open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	print SENDMAIL $from;
	print SENDMAIL $subject;
	print SENDMAIL $to;
	print SENDMAIL "Content-type: text/plain\n\n";
	print SENDMAIL "";
	print SENDMAIL @ipinfo;
	print SENDMAIL "";
	print SENDMAIL "################################################\n";
	print SENDMAIL "# DHCP log entries for [$ipaddress] #\n";
	print SENDMAIL "################################################\n";
	print SENDMAIL @dhcp;
	close(SENDMAIL);
}

#!/bin/perl -w

###########################################################################################
# macwatch.pl: This Perl script actively watches MAC address presence in DHCP logs
# Usecase: This script can be used by Network & Security administrators to monitor network 
# 			nodes via MAC address and send an email message to specific emails address, 
#			such as police office or NOC. This tool uses my iplocator.pl tool from the previous cycle
# Author: 	Hosam M. Badreldin
# Date:		20 September 2016
###########################################################################################
use warnings;
use strict;
use CGI;
use CGI::Carp; # send errors to the browser, not to the logfile

# All variables
my $currentDate = `date +%Y%m%d`;
my $logFile = "/var/logs/dhcp/DHCPD.log.$currentDate"; # must be changed
my $MAC = $ARGV[0];
my $SR = $ARGV[1];
my $matches = 0;
my $ipaddress = 0;
my @data = ();
my @dhcp = ();

my $cgi = CGI->new;
my $MAC = $cgi->param('MAC');
print $cgi->header('text/plain');

print "Script lunched sucessfuly!!\n";
print "Watching for $MAC ... You will recive an email once found!\n";

########### tail -f the DHCP logs #####################
open my $tailf, "tail -f $logFile |" or die;
while (<$tailf>) {
    chomp;
    my $line = $_;
    if($line =~ m/ to $MAC/)
    {
        if (scalar(@dhcp) <= 1){
            push(@dhcp, "$line\n");
			$matches = 1;
        }        
        else {
            last;
        }
    }
}
close $tailf;

## getting IP from DHCP logs
@data = split( ' ', $dhcp[1] );
$ipaddress = $data[10];

# Send email variables
my $sendmail = "/usr/lib/sendmail -oi -t -obq -f SOC\@company.com\n"; # must be changed
my $subject  = "Subject: *** MAC watch result(s) for [$ipaddress / $MAC] - SR#$SR ****\n";
my $to       = "To: abuse\@company.com\n"; #must be changed
my $from     = "From: SOC\@company.com\n"; #Must be changed
my $content  = "";
my $counter  = 0;

###### running iplocator.pl & compiling the email ######
if($matches == 1){
	@ipinfo = `./iplocator.pl $ipaddress`;
	open(SENDMAIL, "|$sendmail") or die "Cannot open $sendmail: $!";
	print SENDMAIL $from;
	print SENDMAIL $subject;
	print SENDMAIL $to;
	print SENDMAIL "Content-type: text/plain\n\n";
	print SENDMAIL "";
	print SENDMAIL @ipinfo;
	print SENDMAIL "";
	print SENDMAIL "################################################\n";
	print SENDMAIL "# DHCP log entries for [$ipaddress / $MAC] #\n";
	print SENDMAIL "################################################\n";
	print SENDMAIL @dhcp;
	close(SENDMAIL);
}

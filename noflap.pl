#!/bin/perl -w

###########################################################################################
# noflap.pl: This scripts runs every 5 minutes in our logging server to look for failures.
# 			 It uses cron job as scheduler.  
# Author: Hosam Badreldin
# Date: 15 October 2016
#####################################################################################
use warnings;
use strict;
use POSIX qw(strftime);

# All variables
my $logsIncDate = strftime('%b %d %H', localtime);
my $logsTimeStamp = strftime('%Y%m%d'  , localtime);
my $currentDate = strftime('%m/%d/%Y %H:%M' , localtime);
my $logFile = "/data/logs/network.log.$logsTimeStamp";
my $sendmailPath = "/usr/lib/sendmail -oi -t -obq -f network\@domain.com\n";
my $subject  = "Subject: **** ALERT: Routing notification message - $currentDate ****\n";
my $from     = "From: network\@domain.com\n";
my $to       = "To: youremail\@domain.com\n";
my @bgp = ();

########### grep through switch logs and if found send e-mail #####################
open SwitchLogs, $logFile or die "Could not open $logFile: $!"; 
while (<SwitchLogs>) {
    chomp;
    push @bgp, "$_ \n" if /$logsIncDate/ && /BGP-5-ADJCHANGE/;
	push @eigrp, "$_ \n" if /$logsIncDate/ && /DUAL-5-NBRCHANGE/;

}
close SwitchLogs;

if(@bgp){
	open(SENDMAIL, "|$sendmailPath") or die "Cannot open $sendmailPath: $!";
	print SENDMAIL $from;
	print SENDMAIL $subject;
	print SENDMAIL $to;
	print SENDMAIL "Content-type: text/plain\n\n";
	print SENDMAIL "";
	print SENDMAIL "BGP related log messages:\n";
	print SENDMAIL "\n";
	print SENDMAIL @bgp;
	print SENDMAIL "\n";
	print SENDMAIL "*** Check edge router logs for more info \n";
	print SENDMAIL "*** "show ip bgp summary" \n";
	close(SENDMAIL);
}
else if(@eigrp){
	open(SENDMAIL, "|$sendmailPath") or die "Cannot open $sendmailPath: $!";
	print SENDMAIL $from;
	print SENDMAIL $subject;
	print SENDMAIL $to;
	print SENDMAIL "Content-type: text/plain\n\n";
	print SENDMAIL "";
	print SENDMAIL "EIGRP related log messages:\n";
	print SENDMAIL "\n";
	print SENDMAIL @eigrp;
	print SENDMAIL "\n";
	print SENDMAIL "*** Check NMS for possible Network outage \n";
	print SENDMAIL "*** Check interal router logs for more info \n";
	close(SENDMAIL);
}


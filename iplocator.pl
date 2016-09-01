#!/bin/perl -w

###########################################################################################
# iplocator.pl: This Perl script returns IP information that helps track a person down. 
# 				It runs various commands on Cisco switches & routers to find the physical
#				location based on what is configured as an interface description. 
# Usecase: This script can be used by Network & Security administrators to precisely locate 
# 			where is traffic coming from, and it can pinpoint to the switch port. 
# 			Can be also used to generate IP reports for law enforcements & court purposes. 
# Author: 	Hosam M. Badreldin
# Date:		01 September 2016
###########################################################################################
use Net::OpenSSH;
use warnings;

# Subroutine prototypes
sub DisplayUsage;
sub Debug_Output;
sub SSHconnect;
sub RouterIP;
sub getL2Info;
sub getRtrName;
sub getVlanName;
sub getSwitchUpLink;
sub MAC2int;
sub intStatus;

# Global variables
$| = 1 ;
$^W = 0 ;
$DEBUG = 0 ;
$sysdate = `date`;

# For security purpose, these credentials must be allocated with limited access to "show" commands only. 
$user = "iplocator";
$pass = "DZ9dDi5(XE!Ad"; # This is a clear text password

# =========================================================================
# Handels command-line switches/arguments [-Debug]
# =========================================================================
while ( $_ = shift( @ARGV ) ) {
   $DEBUG && print( "arg = [$_]\n" );
   switch: {
      if ( $_ eq '-debug' ) {
         $DEBUG++ ;
         $DEBUG && print( "DEBUG = $DEBUG\n" );
         last switch;
      }
      if ( ! defined( $IPNumber ) ) {
         $IPNumber = $_ ;
         $DEBUG && print( "IPNumber = $IPNumber\n" );
         last switch ;
      }
      &DisplayUsage() ;
   }
}
## =========================================================================
# display usage if no IP address specified in the command line
## =========================================================================
if ( ! defined( $IPNumber ) ) {
   &DisplayUsage;
}
# =========================================================================
# Main(): We extract router, switch, VLAN, interface, and MAC information.
# =========================================================================
$RtrIP = &RouterIP;
($MACAddress,$VLANID,$MACAge) = getL2Info();
$RtrName = getRtrName();
$VLAN = getVlanName($VLANID);
$UpLink = getSwitchUpLink($MACAddress,$VLANID);
($SwitchName,$SwitchIP) = getSwitchInfo($UpLink);
$Interface = MAC2int($MACAddress,$VLANID);
($Desc,$Status) = intStatus($Interface);

print( "\n" );
print( "#################################################################\n" );
print( "#\tThe IP locator v1.0 - IP address <> Physical location in LAN\n" );
print( "#\t\tQuery for [$IPNumber]\n" ); 
print( "#\tQuery Date \& Time: $sysdate");
print( "#################################################################\n" );
print( ">> Router:$RtrName\t Router IP:$RtrIP\n" );
print( "-----------------------------------------------------------------\n" );
print( ">> Switch:$SwitchName\t Switch IP:$SwitchIP\n" );
print( "-----------------------------------------------------------------\n" );
print( ">> VLAN: $VLAN\t VLAN#:$VLANID\n" );
print( "-----------------------------------------------------------------\n" );
print( ">> MAC:$MACAddress\t\t Age#:$MACAge minutes\n" );
print( "-----------------------------------------------------------------\n" );
print( ">> Interface:$Interface\t Room#:$Desc\t Status:$Status\n" );
print( "-------------------------End of Report---------------------------\n" );
print( "\n" );

exit(0);

# ====================================================================================
# getL2Info(): SSH to get VLAN#, MAC address, and MAC age - requires router login info
# ====================================================================================
sub getL2Info {
	($SSHtoRouter) = &SSHconnect( $RtrIP, $user, $pass );
	@RouterOutput = $SSHtoRouter->capture( "show ip arp $IPNumber" ) or
	   die( "*** ERROR: Remote system command failed with code: " . ($! >> 8) );
	$DEBUG && Debug_Output(@RouterOutput);

	@Data = split( ' ', $RouterOutput[ $#RouterOutput ] );
	if(@Data) {
		if ( ( $Data[0] eq 'Internet' ) && ( $Data[1] eq $IPNumber ) ) {
			$MAC = $Data[3] ;
			$VID = $Data[5] ;
			$VID =~ s/^vlan//i ;
			$Age = $Data[2];
		}
		return ($MAC,$VID,$Age)
	}
	else { die( "*** Error[show ip arp $IPNumber]: IP Not in ARP table: "); }
}

# ===============================================================
# getRtrName(): returns router name - requires router login info
# ===============================================================
sub getRtrName {
	($SSHtoRouter) = &SSHconnect( $RtrIP, $user, $pass );
	@RouterOutput = $SSHtoRouter->capture( "show running-config | include hostname" ) or
	   die( "*** ERROR: Remote system command failed with code: " . ($! >> 8) );
	$DEBUG && Debug_Output(@RouterOutput);  

	@Data = split( ' ', $RouterOutput[ $#RouterOutput ] );
	if(@Data) {
		if (( $Data[0] eq 'hostname' )) {
			$rname = $Data[1] ;
		}
		else {
			$rname = "<None>"; 
		}
		return $rname;
	}
}

# ========================================================================
# getVlanName(): returns VLAN name - requires router login info & VLANID#
# ========================================================================
sub getVlanName {
	my $vlan = $_[0];
	($SSHtoRouter) = &SSHconnect( $RtrIP, $user, $pass );
	@RouterOutput = $SSHtoRouter->capture( "show vlan | include $vlan" ) or
	   die( "*** ERROR: Remote system command failed with code: " . ($! >> 8) );
	$DEBUG && Debug_Output( @RouterOutput );  

	foreach $Line (@RouterOutput) {
			if ( $Line =~ m/^$vlan / ) {
					@Data = split( ' ', $Line );
					$vname = $Data[1] ;
					last ;
					return $vname;
			}
	}
	die( "*** Error[show vlan | include $vlan]: VLAN doesn't exist on top switch: ") unless $vname;
}
# ==========================================================================================
# getSwitchUpLink(): returns switch uplink interface - requires router login info & MAC
# ==========================================================================================
sub getSwitchUpLink {
	my $mac = $_[0];
	my $vlan = $_[1];
	($SSHtoRouter) = &SSHconnect( $RtrIP, $user, $pass );
	@RouterOutput = $SSHtoRouter->capture( "show mac address address $mac" ) or
	   die( "*** ERROR: Remote system command failed with code: " . ($! >> 8) );
	$DEBUG && Debug_Output( @RouterOutput );  

	my $UpLink;
	foreach $Line (@RouterOutput) {
		if ($Line =~ m/ $vlan /) {
			@Data = split( ' ', $Line );	
			if ($Data[0] == $VLANID) {  
				$UpLink = $Data[3];
			}
			else { #the 6509e
				$UpLink = $Data[6];
			}
			return $UpLink;
		}
	}
	die( "*** Error[show mac address address $mac]: MAC address doesn't exist on top switch: ") unless $UpLink;
}

# ==========================================================================================
# getSwitchInfo(): returns switch name & IP - requires router login info & Uplinks interface
# ==========================================================================================
sub getSwitchInfo {
	my $uplink = $_[0];
	($SSHtoRouter) = &SSHconnect( $RtrIP, $user, $pass );
	@RouterOutput = $SSHtoRouter->capture( "show cdp neighbors $uplink detail" ) or
	   die( " Remote system command failed with code: " . ($! >> 8) );
	$DEBUG && Debug_Output( @RouterOutput );

	my ($SwitchName,$SwitchIP);
	foreach $Line (@RouterOutput) {
		if ($Line =~ m/^Device /) {
			@Data = split( ' ', $Line );
			$SwitchName = $Data[2] ;
			$SwitchName =~ s/\.company\.com//i ; # Must be changed
			last;
		}
	}
	die( "*** Error[Router]: Couldn't find Access switch name in CDP neighbors: ") unless $SwitchName;

	@Data = split( ' ', $RouterOutput[$#RouterOutput] );
	if(@Data) {
		if ($Data[0] eq 'IP') {
			$SwitchIP = $Data[2] ;
		}
	}
	else { die( "*** Error[Router]: Couldn't find Access switch IP in CDP neighbors: "); }
	return ($SwitchName,$SwitchIP)
}

# ===========================================================================================
# MAC2Int(): returns interface corresponding to MAC - requires switch login info, MAC & VLAN
# ===========================================================================================
sub MAC2int {
	my $mac = $_[0];
	my $vlan = $_[1];
	($SSHtoSwitch) = &SSHconnect( $SwitchIP, $user, $pass );
	@SwitchOutput = $SSHtoSwitch->capture( "show mac address address $mac" ) or
	   die( "*** ERROR: Remote system command failed with code: " . ($! >> 8) );
	$DEBUG && Debug_Output( @SwitchOutput );  

	@Data = split( ' ', $SwitchOutput[$#SwitchOutput - 1]);
	if(@Data) {
		if (( $Data[0] eq $vlan )) {
			$int = $Data[3] ;
		}
		return $int
	}
	else { die( "*** Error[show mac address address $mac]: MAC address is not live on access switch: "); }
}
# ===================================================================================
# intStatus(): returns interface information - requires switch login info, interface
# ===================================================================================
sub intStatus {
	my $int = $_[0];
	($SSHtoSwitch) = &SSHconnect( $SwitchIP, $user, $pass );
	@SwitchOutput = $SSHtoSwitch->capture( "show interface $int status" ) or
	   die( " Remote system command failed with code: " . ($! >> 8) );
	$DEBUG && Debug_Output( @SwitchOutput );  

	@Data = split(' ', $SwitchOutput[$#SwitchOutput]);
	if(@Data) {
		if (( $Data[0] eq $int )) {
			$Desc = $Data[1] ;
			$Status = $Data[2] ;
		}
		return ($Desc,$Status)
	}
	else { die( "*** Error[show interface $int status]: Cannot lookup interface info on access switch: "); }
}	

# =============================================================================
# RouterIP(): SSH connection to core router to get the subnet router IP address
# =============================================================================
sub RouterIP {
	my @Octets = split( /\./, $IPNumber );
	my $Chicago = "10.1.255.1"; # Must be changed
	my $Austin = "10.8.22.2"; # Must be changed
	if (($Octets[0] == 10) && ($Octets[1] == 154)) { 
		die( "*** ERROR: Wireless - Cannot be tracked to exact interface, check ACS" );
	}
	if (($Octets[0] == 10) && (($Octets[1] == 186) || ($Octets[1] == 190))) { 
		die( "*** ERROR: R&D networks - Use manual tracing, and lookup static IP information" );
	}
	elsif (($Octets[0] == 10) && ($Octets[1]) >  128) { 
		$CoreRouter = $Austin; 
	}
	elsif (($Octets[0] == 10) && ($Octets[1] < 128)) { 
		$CoreRouter = $Chicago; 
	}
	else {die( "*** ERROR: WRONG IP ADDRESS" ); }	
	
	($SSHtoCore) = &SSHconnect( $CoreRouter, $user, $pass );
	my @CoreOutput = $SSHtoCore->capture( "show ip route $IPNumber" ) or
	die( "*** ERROR[Core]: Remote system command failed with code: " . ($! >> 8) );
	$DEBUG && Debug_Output( @CoreOutput );
	
	my $Subnet;
	foreach $Line ( @CoreOutput ) {
		if ($Line =~ m/^Routing entry for /) {
			@Data = split( ' ', $Line );
			$Subnet = $Data[ 3 ] ;
			last ;
		}
	}
	die( "*** Error[Core]: IP not in routing table of core routers ") unless $Subnet;
	my @Subnet = split( /\./, $Subnet );
	my $RouterIP = join( '.', $Subnet[0], $Subnet[1], $Subnet[2], '1' );
	
	return ($RouterIP)
}

# ======================================================================
# SSHconnect(): general sub used establish SSH connection to remote host
# ======================================================================
sub SSHconnect {
	my $ip = shift; my $user = shift; my $pass = shift;
	my %SSHOptions = ( user => $user,
                 passwd =>  $pass,
                 master_stderr_discard => 1,
                 master_opts => [
                    -o => "UserKnownHostsFile=/dev/null",
                    -o => "StrictHostKeyChecking=no"
                 ],
                 ssh_cmd => '/bin/ssh'
	);
	my $SSH = Net::OpenSSH->new( $ip, %SSHOptions );
	$SSH->error and
		die( " Could not stablish SSH connection: ". $SSH->error );
	return ($SSH);
}

# =============================================================================
# Debug_Output(): prints contents of @Output[] to the STDOUT
# ==============================================================================
sub Debug_Output {
   my(@Output) = @_ ;
   my( $l, $Line, @Data, $i, $Value );

   $l = 0 ;
   foreach $Line (@Output) {
      $Line =~ s/[\r\n]//g ;
      print( '  ', $l, " Line = $Line\n" );
      $l++ ;
      @Data = split(' ', $Line);
      $i = 0 ;
      foreach $Value (@Data) {
         print( '    ', $i, " = $Data[ $i ]\n" );
         $i++ ;
      }
   }
}

# ======================================================================
#  DisplayUsage():  Subroutine to display script usage.
# ======================================================================
sub DisplayUsage {
   print(":: The IP Locator v1.0 ::\n");
   print("Usage:  $0 [-debug] IPAddress");
   print("\n");
   print("\n");
   exit(1);
}

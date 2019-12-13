#!/usr/bin/perl
#
#   knockgen 0.1 - Random port & protocol sequence generator for knockd daemon
#   Copyright (C) 2018  Pekka Helenius
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#-----------------------------------------
# PROGRAM DESCRIPTION

# This perl program generates a random port & protocol sequence for knockd daemon.
# This generated sequence can be used to knock ports of the target machine (usually a SSH server behind a firewall).
# The generated data must be equal for the server (knockd daemon computer) and your client (ssh/knock client computer).

#-----------------------------------------
# ENVIRONMENT

use strict;
use warnings;

# For CLI input parameters
use Getopt::Long;

# For help text
use Pod::Usage;

# For IP regular expressions
# Requires 'perl-regexp-common' package (e.g. Arch Linux package database)
use Regexp::Common qw/net number/;

# Requires 'perl-io-socket-inet6' package (e.g. Arch Linux package database)
use IO::Socket;

# For pinging target hosts
use Net::Ping;


# TODO output file (Default: /etc/knockd.conf)
    # Check if the file exists
        # Do same checks than in the bash script
        
# Ask user for these
# TODO knockd daemon: Configuration file? [default: /etc/knockd.conf ]
# TODO knockd daemon: Network interface for daemon? [default: eth0 ]
# TODO knockd daemon: Time limit for port knocking in seconds? [default: 10 ]
# TODO knockd daemon: Ports to be opened after knocking? [default: 22 ]
# TODO knockd daemon: Open port for specified IP or any client? [default: any ]
# TODO knockd daemon: How long to keep the port opened in seconds? [default: 15 ]
# TODO knockd daemon: TCP Flags? [default: syn ]
# TODO knockd daemon: Use log file /var/log/knockd.log? [default: n]

# TODO If previous knockd configuration detected (get creation date of it), warn sysadmin about it
# TODO add commented date tag to generated knockd.conf file (for sysadmins)
# TODO Ask user if the generated port sequence pattern is ok or generate a new one
# TODO if output/override etc parameter is given with valid input, use it instead of generating a new one

# TODO detect old SSH configurations from /etc/iptables/*.rules files. Warn user about them and delete if permission granted
#       Do this by detecting the the ports which should be opened by knockd

# TODO support for multiple port openings. Can we do this just by adding a new port to IPTABLES rule or do we have to generate a new
# rule for each port?

#-----------------------------------------
# DEFAULT VALUES
#
# Port test before generating values for knockd.
# We need testing because we want to avoid any ports which may be listened/used by a running server daemon.
#
my $default_target_ip                   = "127.0.0.1"; # IPv4 address of the target host computer. Default: 127.0.0.1
my $connection_timeout                  = 0.3; # Connection timeout in seconds. Default: 0.3
my $connection_timeout_minlimit         = 0.2; # This is the minimum time out limit for connection attempts
my $connection_timeout_maxlimit         = 5.0; # This is the maximum time out limit for connection attempts

# Knockd specific values
my $knockd_protocols                    = "tcp,udp"; # Protocols to be used. Only tcp or udp is accepted.
my $knockd_port_count                   = 6; # How many port and protocol combinations we generate for knockd input.
my $knockd_port_count_limit             = 30; # This is the maximum amount of ports accepted to output.
my ($knockd_min_port, $knockd_max_port) = (1, 65535); # Scanned port range. Default: 1, 65535

# TODO override port pattern
# TODO override port + protocol pattern

# TODO parameter: output pattern only, no knockd questions described above

# TODO knockd_protocols: check for input values (must be either tcp or udp, max values (array length) is 2"
# TODO knockd_port_count: set minimum limit to 2

# TODO check for iptables Default policy, too (does it reject all traffic etc)
#/usr/bin/iptables -I INPUT -p tcp -dport 5461 -j ACCEPT
#/usr/bin/iptables -D INPUT -p tcp -dport 5461 -j ACCEPT

#-----------------------------------------
# USER INPUT PARAMETERS

my %opts = ("all"            => 0,
            "ports-only"     => 0,
            "target-ip"      => $default_target_ip,
            "dry-gen"        => 0,
            "random-always"  => 0);

GetOptions ("a|all"            => \$opts{"all"},
            "p|ports-only"     => \$opts{"ports-only"},
            "i|target-ip=s"    => \$opts{"target-ip"},
            "d|dry-gen"        => \$opts{"dry-gen"},
            "r|random-always"  => \$opts{"random-always"},
            "t|conn-timeout=f" => \$connection_timeout,
            "c|protocols=s"    => \$knockd_protocols,
            "m|min-port=i"     => \$knockd_min_port,
            "x|max-port=i"     => \$knockd_max_port,
            "n|port-count=i"   => \$knockd_port_count,
            "h|help"           => sub { pod2usage(1) })
or pod2usage(2);

my $all             = $opts{"all"};
my $ports_only      = $opts{"ports-only"};
my $target_ip       = $opts{"target-ip"};
my $dry_gen         = $opts{"dry-gen"};
my $random_always   = $opts{"random-always"};

#-----------------------------------------
# ERROR HANDLING

# We don't accept regular PERL arguments here. We take arguments only from GetOptions
# Perl arguments are handled differently, we don't want them.
if (@ARGV)
{
    print "Unknown option: @ARGV\n";
    pod2usage(2);
}

#--------------------
# If 'target_ip' is default value and 'dry-gen' is set, clear the IP value.
if ($target_ip eq $default_target_ip and $dry_gen) {
    print "WARNING: Not testing whether generated ports are being used or not.\n";
    undef $target_ip;
}

#--------------------
# If both 'dry-gen' and 'target_ip' is set, terminate.
if ($target_ip and $dry_gen) {
    die "ERROR: Define either target IPv4 address or 'dry-gen' parameter.\n";
}

#--------------------
# If neither 'ports-only' or 'all' hash is set, use default 'all' value.
if (not $ports_only and not $all) {
    $all = 1;
}

#--------------------
# If both 'ports-only' and 'all' is set, terminate.
if ($ports_only and $all) {
    die "ERROR: Define either 'ports-only' or 'all' (default is 'all').\n";
}

#--------------------
# If more than allowed ports have been instructed.
if ($knockd_port_count > $knockd_port_count_limit) {
    die "ERROR: Maximum number of ports is " . $knockd_port_count_limit . ". You have defined " . $knockd_port_count . " ports.\n"
}

#--------------------
# Check for invalid port values (min & max)
my $port_fault = "";
if (($knockd_min_port < 1) or ($knockd_min_port > 65535))
{
    print "ERROR: Minimum port value is not in valid range 1-65535 (Value: " . $knockd_min_port . ")\n";
    $port_fault = "true";
}

if (($knockd_max_port < 1) or ($knockd_max_port > 65535))
{
    print "ERROR: Maximum port value is not in valid range 1-65535 (Value: " . $knockd_max_port . ")\n";
    $port_fault = "true";
}

# If faulty port values, exit the program
# We define the exit procedure separately because we want to print all previous port-related error messages
if ( $port_fault eq "true" ) { exit }

#--------------------
# Inform user that the minimum port value exceeds maximum port value.
if ($knockd_min_port > $knockd_max_port) 
{
    die "ERROR: Minimum port value is set above maximum port value.\n";
}

#--------------------
# Inform user that more random ports must be available in the given pool.
if (($knockd_max_port - $knockd_min_port) < $knockd_port_count)
{
    die "ERROR: You must have more ports for randomizable port sequence (Current port pool size: " . ($knockd_max_port - $knockd_min_port) . ")\n";
}

#--------------------
# Minimum connection time out value can't be less than the limit value defines.
if ($connection_timeout < $connection_timeout_minlimit)
{
    die "ERROR: Connection time out can't be set below " . $connection_timeout_minlimit . " seconds.\n";
}

# Maximum connection time out value can't exceed the maximum limit value.
if ($connection_timeout > $connection_timeout_maxlimit)
{
    print "WARNING: Connection time out limit is set above recommended limit (" . $connection_timeout_maxlimit . " seconds).\n";
}

#--------------------
# If user is not having dry-gen parameter set...
if (not $dry_gen) {

    # ...check for valid IP address syntax.
    if (not $target_ip =~ /^$RE{net}{IPv4}$/ or $target_ip eq "localhost") {
        die "ERROR: Invalid IPv4 address given (" . $target_ip . ")\n"
    }

    # ... check that we can establish a connection to the target IP address.
    my $p = Net::Ping->new;
    if (not $p->ping($target_ip, $connection_timeout_maxlimit)) {
        die "ERROR: Can't find the host computer.\n"
    }
}

#-----------------------------------------
# PORT & PROTOCOL GENERATION

# Split user input into a new array, defined by @ symbol.
my @knockd_protocols = split /,/, $knockd_protocols;

# Set port range.
my @knockd_port_range = ($knockd_min_port .. $knockd_max_port);

# Declare a new array for generated ports (+ protocols).
# Fill with zeros, size is value of $knockd_port_seqs.
my @randoms = (0) x $knockd_port_count;

my $i = 0;
while ($knockd_port_count > 0)
{

    while ()
    {

        # Generate a random port from given port range.
        my $random_port = $knockd_port_range[rand @knockd_port_range];

        # Choose randomly between protocols tcp & udp.
        my $random_protocol = $knockd_protocols[rand @knockd_protocols];

        # TODO make this optional with '$always_random' user input parameter
        # Never accept already generated port in port sequence.
        if (not grep {$_ =~ /$random_port/} @randoms)
        {

            # Initialize socket value
            my $socket = 0;

            if (not $dry_gen) {

                # Test the generated port for a connection.
                # Protocol must always be else than udp because udp doesn't give
                # a response whether the connection was successful or not.
                # This is in the procotol specification.
                #
                # Therefore, udp would fail the connection test we establish here
                #
                $socket = IO::Socket::INET->new(PeerHost => $target_ip,
                                                PeerPort => $random_port,
                                                Proto    => "tcp", #This is hardcoded purposefully
                                                Timeout  => $connection_timeout);

            }
            else 
            {
                undef $socket;
            }

            # If socket dest is not used
            if (not $socket)
            {
                if ( $all ) {
                    $randoms[$i] = $random_port . ":" . $random_protocol;
                }
                else
                {
                    $randoms[$i] = $random_port;
                }
                last;
            }
        }
    }
    $knockd_port_count--;
    $i++;
}

my $knockd_seqs = join(',', @randoms);
print $knockd_seqs . "\n";

#-----------------------------------------
# HELP TEXT

__END__

# TODO IMPROVE THIS SECTION
# TODO UPDATE HELP TEXT TO CORRESPOND WITH THE COMMANDS ABOVE

=head1 SYNOPSIS

knockgen [options] (--help or -h for more information)
    
knockgen 0.1 - Random port & protocol sequence generator for knockd daemon


    knockgen  Copyright (C) 2018 Pekka Helenius <fincer89@hotmail.com>
    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

    
=head1 OPTIONS

=item A<------------------------------>

=item A<Output format:>

=item B<--all> or B<-a>

Print randomly generated ports & protocols (Default)

=item B<--ports-only> or B<-p>

Print randomly generated ports only

=item B<--dry-gen> or B<-d>

Generate port (& protocol) sequence without trying to connect anywhere.

=item A<------------------------------>

=item A<Port testing:>

=item B<--target-pc> or B<-i>
            
IPv4 address of the target computer (server). Default: 127.0.0.1

=item B<--protocols> or B<-c>

Use these protocols. Default: tcp,udp (Syntax: tcp or tcp,udp)

=item B<--conn-timeout> or B<-t>

Connection timeout for a port test in seconds. Default: 0.3

=item A<------------------------------>

=item A<Generated values:>

=item B<--min-port> or B<-m>

Minimum port number to be used for knockd daemon. Default: 1

=item B<--max-port> or B<-x>

Maximum port number to be used for knockd daemon. Default: 65535

=item B<--port-seqs> or B<-n>

Number of port (+ protocol) sequences for knockd daemon. Default: 6

=item B<--help> or B<-h>

Prints this help text.

=cut

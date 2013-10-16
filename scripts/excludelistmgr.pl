#!/usr/bin/perl
#
# Manage NetBackup client exclude lists for multiple clients at once.
#
# Author: Andreas Skarmutsos Lindh
#

#use strict;
use warnings;
use Getopt::Std;
use Data::Dumper;

my $bpgetconfigbin = "/usr/openv/netbackup/bin/admincmd/bpgetconfig";
my $bpsetconfigbin = "/usr/openv/netbackup/bin/admincmd/bpsetconfig";

my %opt;
getopts('a:p:c:f:e:dh?', \%opt) or output_usage();
output_usage() if $opt{'h'};

sub output_usage
{
	my $usage = "Usage: $0 [options]

	Options:
		-a <add/del/replace>		Action to perform
		-p <policy>					Policy for which clients will be affected
		-c <client>					Client which will be affected
		-f <file>					File containing exclude list
		-e <exclude string>			String to exclude
		-d 							Debug.
	\n\n";

	die $usage;
}


sub debug
{
	my $level = $_[0];
	my $msg = $_[1];
	if ($opt{'d'})
	{
		print "<$level> DEBUG: $msg\n";
	}
}

# Some basic functions

# Select what to get from bpgetconfig
# &bpgetconfig("xyz.zz.hm.com", "SERVER")
sub get_excludes
{
	$client = $_[0];
	$type = "EXCLUDE";
	#&debug(1, "Calling: $bpgetconfigbin -M $client $type");
	my @output = `$bpgetconfigbin -M $client $type`;
    return @output;
}


sub main
{
	local $client = $opt{'c'};
	#&debug(1, "Client: $client");
	@excludelist = &get_excludes($client);
	print Dumper(@excludelist);
	$newexclude = $opt{'e'};
	#$newexclude =~ s/\\/\\\\/g;
	#&debug(1, "New exclude to add $newexclude")
	#&debug(1, "Excludelist before addition: @excludelist");
	foreach (@excludelist) 
	{
		if ($_ =~ m/($newexclude)/)
		{
			&debug(1, "New exclude \($newexclude\) already in list, skipping");
		}
		else
		{
			push(@newlist, $newexclude);
		}
	}
	push(@excludelist, @newlist);
	print Dumper(@excludelist);
	#&debug(1, "Excludelist after addition: $excludelist");
}
main()

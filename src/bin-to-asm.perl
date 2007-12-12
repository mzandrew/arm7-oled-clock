#!/usr/bin/perl -w

# copyright 2007 mza (Matthew Andrew)
# started 2007-09-19 (talk like a pirate day)

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA
# or visit http://www.fsf.org/

use strict;
use lib '/home/bin/nofizbin/perl';
use DebugInfoWarningError;

$DebugInfoWarningError::verbosity{"STD"}->{"debug"} = 1;
my ($source, $destination);
my $okay_for_source_to_be_the_same_as_destination = 0;
my $okay_for_destination_to_not_yet_exist = 1;

sub usage {
	if ($okay_for_source_to_be_the_same_as_destination) {
		print <<endofline;
usage:
  $0 source [ destination ]
if only one argument is given, the destination will be the same as the source
endofline
	} else {
		print <<endofline;
usage:
  $0 source destination
endofline
	}
}

if ($#ARGV == -1) {
	error("no arguments given");
	usage();
	exit(1);
} elsif ($#ARGV < 1) {
	debug("destination = source");
	unless ($okay_for_source_to_be_the_same_as_destination) {
		error("destination = source, which is not allowed");
		exit(2);
	}
	$source      = $ARGV[0];
	$destination = $source;
} elsif ($#ARGV == 1) {
	debug("separate source and destination");
	$source      = $ARGV[0];
	$destination = $ARGV[1];
	debug("source = \""      . $source      . "\"");
	debug("destination = \"" . $destination . "\"");
}

sub check_source {
	if (! -e $source) {
		error("cannot find source \"" . $source . "\"");
		exit(3);
	}
	if (! -r $source) {
		error("cannot read source \"" . $source . "\"");
		exit(4);
	}
}

sub check_destination {
# test $okay_for_destination_to_not_yet_exist
	if (-e $destination) {
		if (0) {
			debug("destination \"" . $destination . "\" already exists");
			if (-w $destination) {
				debug("truncating destination \"" . $destination . "\"");
			} else {
				error("cannot write to destination \"" . $destination . "\"");
				exit(5);
			}
		} else {
			debug("destination \"" . $destination . "\" already exists");
			if (! -w $destination) {
				error("cannot write to destination \"" . $destination . "\"");
				exit(6);
			}
		}
	}
}

check_source();
check_destination();

unless (open(SOURCE, $source)) {
	error(7, "can't open file \"$source\"");
};

unless (open(DESTINATION, ">$destination")) {
	error(8, "can't open file \"$destination\"");
};

my ($buffer_1, $buffer_2, $buffer_3, $buffer_4);

my $source_name = $source;
$source_name =~ s/-/_/g;
$source_name =~ s/\./_/g;
print(DESTINATION "\n.text");
print(DESTINATION "\n.align 4");
print(DESTINATION "\n.global $source_name");
print(DESTINATION "\n$source_name:");
print(DESTINATION "\n	.word ");
info($source_name);

my $length = 256;
my $i=0;
while ($length != 0) {
	$length = read(SOURCE, $buffer_1, 1, 0);
	$length = read(SOURCE, $buffer_2, 1, 0);
	$length = read(SOURCE, $buffer_3, 1, 0);
	$length = read(SOURCE, $buffer_4, 1, 0);
#	chomp($line);
#	debug($line);
	if ($length>0) {
		if ($i>0 && $i<=15) {
			print(DESTINATION ", ");
		}
		printf(DESTINATION "0x");
		printf(DESTINATION "%02x", ord($buffer_4));
		printf(DESTINATION "%02x", ord($buffer_3));
		printf(DESTINATION "%02x", ord($buffer_2));
		printf(DESTINATION "%02x", ord($buffer_1));
		$i++;
		if ($i>15) {
			$i=0;
			print(DESTINATION "\n	.word ");
		}
	}
	if ($length==0) {
		print(DESTINATION "\n\n");
	}
}

close(SOURCE);
close(DESTINATION);


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

use Image::BMP;

my $number_of_bits_to_keep_per_channel;
my $number_of_bytes_to_use_per_pixel;
my $packed = 1;

if ($packed) {
	$number_of_bytes_to_use_per_pixel = 2;
	$number_of_bits_to_keep_per_channel = 5;
} else {
	$number_of_bytes_to_use_per_pixel = 4;
	$number_of_bits_to_keep_per_channel = 6;
}

my $input_image = new Image::BMP;
$input_image->open_file($source);

unless (open(DESTINATION, ">$destination")) {
	error(8, "can't open file \"$destination\"");
};

my ($x, $y) = (0, 0);
my ($width, $height) = ($input_image->{Width}, $input_image->{Height});
debug("width=".$width);
debug("height=".$height);
my $buffer = pack("S", $width);
syswrite(DESTINATION, $buffer, 2);
$buffer = pack("S", $height);
syswrite(DESTINATION, $buffer, 2);
#for ($y=$height-1; $y>=0; $y--) {
for (my $y=0; $y<$height; $y++) {
	for (my $x=0; $x<$width; $x++) {
		my ($r, $g, $b) = $input_image->xy_rgb($x, $y);
#			debug($r); debug($g); debug($b);
		my $number_of_bits_to_shift = 8 - $number_of_bits_to_keep_per_channel;
		$r=int($r>>$number_of_bits_to_shift); $g=int($g>>$number_of_bits_to_shift); $b=int($b>>$number_of_bits_to_shift);
#			debug($r); debug($g); debug($b);
		my $color = ($r<<(2*$number_of_bits_to_keep_per_channel)) + ($g<<$number_of_bits_to_keep_per_channel) + $b;
#			debug($color);
	
#			printf("\n%08x", $color);
#			printf(DESTINATION "%0x", $color);

		if ($number_of_bytes_to_use_per_pixel==4) {
			$buffer = pack("L", $color);
			syswrite(DESTINATION, $buffer, 4);
		} elsif ($number_of_bytes_to_use_per_pixel==2) {
			$buffer = pack("S", $color);
			syswrite(DESTINATION, $buffer, 2);
		} else {
			error(14, "number_of_bytes_to_use_per_pixel = $number_of_bytes_to_use_per_pixel not yet implemented");
		}
	}
}


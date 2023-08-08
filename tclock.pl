#!/usr/bin/env perl

# This is simple analog clock with hour and minute hand.
# (C)2023 by tvierb
# License: GPL 3.0

use strict;
use warnings;
use FindBin;
use Getopt::Long;
use lib "$FindBin::Bin";
use TClock;
$|=1;

GetOptions(
	'stretch=s' => \my $stretch,
	'delay=s'   => \my $delay,
	'help|?'    => \my $help,
);

die("\n$0 [--delay 15] [--stretch 2.25] [--help]\n") if $help;

$stretch //= 2.2;
$stretch += 0;
$delay //= 15;

my $tc = TClock->new( stretch => $stretch );

while(4e4)
{
	$tc->update();
	$tc->draw();
	sleep ( $delay );
}


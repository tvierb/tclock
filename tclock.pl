#!/usr/bin/env perl

# This is simple analog clock with hour and minute hand.
# (C)2023 by tvierb
# License: GPL 3.0

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin";
use TClock;
$|=1;

my $tc = TClock->new();

while(4e4)
{
	$tc->update();
	$tc->draw();
	sleep ( 5 );
}


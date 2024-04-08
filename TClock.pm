package TClock;

use strict;
use warnings;
use POSIX qw(strftime);
use Math::Round;
use Data::Dumper;

sub new
{
	my $class = shift;
	my %params = @_; # mode="decimal-time"
	my $self = bless({}, $class);
	$self->{ stretch } = $params{"stretch"} // 2.2;
	$self->set_mode( $params{"mode"} );
	$self->update();
	return $self;
}

sub set_mode
{
	my $self = shift;
	my $mode = shift // "standard12";
	if ($mode eq "standard12")
	{
		$self->set_standardclock();
	}
	elsif ($mode eq "standard24")
	{
		$self->set_24_hour_clock();
	}
	elsif ($mode eq "decimal-time")
	{
		$self->set_decimal_time();
	}
	else {
		die("unknown mode");
	}
}

sub set_standardclock
{
	my $self = shift;
	$self->{ hours_per_day }      = 24;
	$self->{ wrap_hours }         = 12;
	$self->{ minutes_per_hour }   = 60;
	$self->{ seconds_per_minute } = 60;
	$self->{ seconds_factor } = 1;
	$self->{ mode } = "standard12";
}

sub set_24_hour_clock
{
	my $self = shift;
	$self->{ hours_per_day }      = 24;
	$self->{ wrap_hours }         = 24;
	$self->{ minutes_per_hour }   = 60;
	$self->{ seconds_per_minute } = 60;
	$self->{ seconds_factor } = 1;
	$self->{ mode } = "standard24";
}

sub set_decimal_time
{
	my $self = shift;
	$self->{ hours_per_day }      = 10;
	$self->{ wrap_hours }         = 10;
	$self->{ minutes_per_hour }   = 100;
	$self->{ seconds_per_minute } = 100;
	$self->{ seconds_factor } = 1/0.864;
	$self->{ mode } = "decimal-time";
}

sub update
{
	my $self = shift;
	# calculate the ticks:
	my $hour_ticks = $self->{minutes_per_hour} * $self->{seconds_per_minute};
	my ($h, $m, $s) = split(/ /, strftime("%H %M %S", localtime()));
	my $hh = $h % $self->{ wrap_hours };
	my $ticks = ($hh * $hour_ticks) + ($m * $self->{ seconds_per_minute }) + $s;
	$ticks *= $self->{ seconds_factor }; # decimal time has shorter seconds
	$self->{ ticks } = $ticks;
	$self->{ time  } = [ $h, $m, $s ];

	$self->{ lines } = `tput lines`;
	$self->{ cols }  = `tput cols`;
	$self->{ cx } = int( $self->{ cols  } / 2);
	$self->{ cy } = int( $self->{ lines } / 2);
	$self->{ maxlen } = $self->{ cx };
	$self->{ maxlen } = $self->{ cy } if $self->{ cy } < $self->{ cx };
	$self->{ maxlen } -= 2;
}


sub draw
{
	my $self = shift;
	system("tput clear");
	$self->draw_clockface();
	$self->draw_hands();
	if ($self->{mode} eq "decimal-time")
	{
		my $text = "";
		$text .= sprintf("%.4f", $self->{ ticks } / ($self->{ seconds_per_minute } * $self->{ minutes_per_hour }));
		$text .= sprintf(" aka %2d:%2d:%2d", $self->{ time }->[0], $self->{ time }->[1], $self->{ time }->[2]);
		print $text;
	}
}

sub draw_hands
{
	my $self = shift;
	my $hour_ticks = $self->{minutes_per_hour} * $self->{seconds_per_minute};
	my $decimal_hours = $self->{ ticks } / $hour_ticks;
	# print "decimal_hours = $decimal_hours\n";
	my $hour_hand_angle = $decimal_hours * 2 * 3.14159265 / $self->{ wrap_hours };
	$self->draw_hand( $self->{ maxlen } * 5 / 8, $hour_hand_angle, "H" );

	my $ti = $self->{ ticks } % $hour_ticks; # cut hours
	my $decimal_minutes = $ti / $hour_ticks; # devide into fraction
	my $minutes_hand_angle = $decimal_minutes * 2 * 3.14159265;
	# print "mph=" . $self->{ minutes_per_hour } . "\n";
	$self->draw_hand( $self->{ maxlen } - 1, $minutes_hand_angle, "M" );
	$self->draw_point( 1, 1, " ");
}

sub draw_point
{
	my ($self, $x, $y, $what) = @_;
	$what //= "?";
	# print "$x, $y, $what\n";
	print "\e[" . round($y) . ";" . round($x) . "H" . $what;
}

sub draw_clockface
{
	my $self = shift;
	for (my $minute = 0; $minute < $self->{ minutes_per_hour }; $minute++)
	{
		my $angle = $minute * 2 * 3.14159265 / $self->{ minutes_per_hour };
		$angle += 3 * 3.14159265 / 2;
		my $dotx = cos( $angle ) * $self->{ maxlen };
		my $doty = sin( $angle ) * $self->{ maxlen };
		my $dot = ".";
		# hour markers on standard 12hr clock:
		my $dot_each = 5;
		if ($self->{hours_per_day} == 10)
		{
			$dot_each = 10;
		}
		unless ($minute % $dot_each)
		{
			$dot = $minute / $dot_each;
			$dot ||= $self->{wrap_hours}; # top value on top
		}
	
		# todo 24hr clock

		$self->draw_point(
			$self->{ cx } + ( $self->{ stretch } * $dotx ),
			$self->{ cy } + $doty,
			$dot );
	}
}

sub draw_hand
{
	my ($self, $len, $angle, $dot) = @_;
	for (my $i = 0; $i <= $len; $i += 0.2)
	{
		my $x = cos( $angle + ( 3 * 3.14159265 / 2 ) ) * $i;
		my $y = sin( $angle + ( 3 * 3.14159265 / 2 ) ) * $i;
		$self->draw_point(
			$self->{ cx } + ( $self->{ stretch } * $x ), # stretch it!
			$self->{ cy } + $y,
			$dot );
	}
}

1;

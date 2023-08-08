package TClock;

use strict;
use warnings;
use POSIX qw(strftime);
use Math::Round;

sub new
{
	my $class = shift;
	my %params = @_;
	my $self = bless({}, $class);
	$self->{ stretch } = $params{"stretch"} // 2.2;
	$self->update();
	return $self;
}

sub update
{
	my $self = shift;
	$self->{ time } = [ split(/ /, strftime("%H %M %S", localtime())) ];
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
	my $h = $self->{ time }->[ 0 ] % 12;
	my $m = $self->{ time }->[ 1 ];
	my $s = $self->{ time }->[ 2 ];

	my $hms = $h + ($m / 60) + ($s / 3600);
	my $hangle = $hms * 2 * 3.14159265 / 12;
	$self->draw_hand( $self->{ maxlen } * 5 / 8, $hangle, "H" );

	my $ms = $m + ($s / 60);
	my $mangle = $ms * 2 * 3.14159265 / 60;
	$self->draw_hand( $self->{ maxlen } - 1, $mangle, "M" );
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
	for (my $minute = 0; $minute < 60; $minute++)
	{
		my $angle = $minute * 2 * 3.14159265 / 60;
		$angle += 3 * 3.14159265 / 2;
		my $dotx = cos( $angle ) * $self->{ maxlen };
		my $doty = sin( $angle ) * $self->{ maxlen };
		my $dot = ".";
		unless ($minute % 5)
		{
			$dot = $minute / 5;
			$dot ||= 12;
		}
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

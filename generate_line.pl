#!/usr/bin/perl
# made by: KorG
# Example usage:
# ./generate_line.pl -A 5 -B 8 -x0 -5 --spread 1 -c 1000000 --step 0.3 > file
# ./LinearApprox < file

use strict;
use warnings;
use Getopt::Long;

sub usage {
   warn "Usage: $0 <--A=NUM --B=NUM> [OPTIONS]
   --A         A coefficient
   --B         B coefficient
   --count     Number of points to be generated
   --help      Show this message
   --seed      Random seed
   --spread    Height of random spread (y = +- spread / 2)
   --step      Average step between points
   --x0        Starting point on X axis
   \n";
   q();
}

my %opts;
GetOptions(
   \%opts, qw( A=s B=s count=i seed=s spread=s step=s x0=s help! )
);

die usage if defined $opts{help};

# Assign mandatory parameters
my ($A, $B) = @opts{qw( A B )};

# Prepare frequently used variables
my ($spread, $step) = (0, 1);

# Assign optional parameters
$spread = $opts{spread} if defined $opts{spread};
$step = $opts{step} if defined $opts{step};

# Append default values
%opts = (
   count => 10,
   x0 => 0,
   %opts
);

# Check if the user specified A and B
die usage unless defined $A and defined $B;

# Prepare math engine
my ($x, $y) = $opts{x0};
my $count = $opts{count};
srand($opts{seed}) if defined $opts{seed};

# Stuff for deltas -- to estimate A deviation due to random spread
my $real_delta_size = int($count / 2) - 1;
my $real_delta_divider = $count / 100 + $count / $real_delta_size;
my @real_deltas;

while ($count > 0) {
   $y = $A * $x + $B;

   # If spread is required, add it to Y and save into real_deltas by index
   if ($spread > 0) {
      my $delta = rand($spread) - $spread / 2;
      $real_deltas[int($count / $real_delta_divider)] += $delta;
      $y += $delta;
   }

   # Print to stdout
   print "$x $y\n";

   # Prepare for the next step
   $x += $step;
   $count--;
}

# Print delta statistics if there was some random in data
if ($spread > 0) {
   warn join("\n", "Real deltas: ", reverse(@real_deltas)) . "\n";
}

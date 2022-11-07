#!/usr/bin/perl
# made by: KorG
# Example usage:
# ./generate_line.pl --A=8 --B=7 --step=0.3 --count=1000000 | ./LinearApprox

use strict;
use v5.18;
use warnings;
no warnings 'experimental';
use utf8;
binmode STDOUT, ':utf8';

sub usage {
   warn "Usage: $0 <--A=NUM --B=NUM> [OPTIONS]
   --A         A coefficient
   --B         B coefficient
   --count     Number of points to be generated
   --seed      Random seed
   --spread    Height of random spread (y = +- spread / 2)
   --step      Average step between points\n";
   q();
}

use Getopt::Long;
my ($A, $B);
my $count = 10;
my $seed;
my $spread = 10;
my $step = 1;
GetOptions (
   "A=i" => \$A,
   "B=i" => \$B,
   "count=i" => \$count,
   "seed=i" => \$seed,
   "spread=i" => \$spread,
   "step=s" => \$step,
) or die usage;

die usage unless defined $A and defined $B;

my $x = 0;
my $y;
srand($seed) if defined $seed;

while ($count-- >= 0) {
   $y = $A * $x + $B;
   $y += rand($spread) - $spread / 2;
   print "$x $y\n";
   $x += $step;
}

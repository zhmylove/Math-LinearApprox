#!/usr/bin/perl
# made by: KorG
# Example usage:
# ./calculate_error.pl -origA 5 -origB 8 -testA 4.989169 -testB 8.048390 \
#     -x0 0 -count 10

use strict;
use warnings;
use List::Util qw( sum );
use Getopt::Long;

sub usage {
   warn "Usage: $0 <OPTIONS>
   --origA     A coefficient of the original line
   --origB     B coefficient of the original line
   --testA     A coefficient of the line being tested
   --testB     B coefficient of the line being tested
   --count     Number of points to be generated
   --help      Show this message
   --step      Average step between points
   --x0        Starting point on X axis
   \n";
   q();
}

my %opts;
GetOptions(
   \%opts, qw( origA=s origB=s testA=s testB=s count=i step=s x0=s help! )
);

die usage if defined $opts{help};

# Assign mandatory parameters
my ($origA, $origB, $testA, $testB) = @opts{qw( origA origB testA testB )};

# Append default values
%opts = (
   step => 1,
   count => 10,
   x0 => 0,
   %opts
);

# Check if the user specified A and B
die usage if grep {not defined $opts{$_}} qw( origA origB testA testB );

# Prepare math engine
my ($x, $y) = $opts{x0};
my $count = $opts{count};
my @deltas;

while ($count > 0) {
   # Save current delta
   push @deltas, ($testA * $x + $testB) - ($origA * $x + $origB);

   # Prepare for the next step
   $x += $opts{step};
   $count--;
}

warn "Aggregate error: ", sum(@deltas), "\n";

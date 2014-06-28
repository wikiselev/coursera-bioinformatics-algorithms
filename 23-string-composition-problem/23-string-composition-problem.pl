#!usr/bin/perl -w

# Input: An integer k and a string Text.
# Output: Compositionk(Text), where the k-mers are written in lexicographic order.

# Sample Input:
# 5
# CAATCCAAC

# Sample Output:
# AATCC
# ATCCA
# CAATC
# CCAAC
# TCCAA

use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

my $k = $data[0];
chomp $k;

my $Text = $data[1];
chomp($Text);

my @Composition;

for (my $i = 0; $i <= length($Text) - $k; $i++) {
	push ( @Composition, substr($Text, $i, $k) );
}

@Composition = sort { $a cmp $b } @Composition;

print join("\n", @Composition);
print "\n";

exit;

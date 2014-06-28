#!usr/bin/perl -w

# CODE CHALLENGE: Solve the Overlap Graph Problem (restated below).
# Input: A collection Patterns of k-mers.
# Output: The overlap graph Overlap(Patterns), in the form of an adjacency list.

# Sample Input:
# ATGCG
# GCATG
# CATGC
# AGGCA
# GGCAT

# Sample Output:
# AGGCA -> GGCAT
# CATGC -> ATGCG
# GCATG -> CATGC
# GGCAT -> GCATG

use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @nodes = <F>;
close F;

chomp(@nodes);
@nodes = sort { $a cmp $b } @nodes;

sub Prefix {
	return ( substr ( $_[0], 0, length ( $_[0] ) - 1 ) );
}

sub Suffix {
	return ( substr ( $_[0], 1, length ( $_[0] ) - 1 ) );
}

my $Pattern1;
my $Pattern2;

open (F, '>output.txt');
foreach $Pattern1 ( @nodes ) {
	foreach $Pattern2 ( @nodes ) {
		if ( &Suffix ( $Pattern1 ) eq &Prefix ( $Pattern2 ) ) {
			print F join(" -> ", $Pattern1, $Pattern2);
			print F "\n";
		}

	}
}
close F;

exit;

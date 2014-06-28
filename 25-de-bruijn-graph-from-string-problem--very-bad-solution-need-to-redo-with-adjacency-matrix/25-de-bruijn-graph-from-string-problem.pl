#!usr/bin/perl -w

# CODE CHALLENGE: Solve the De Bruijn Graph from a String Problem.
# Input: An integer k and a string Text.
# Output: DeBruijnk(Text).

# Sample Input:
# 4
# AAGATTCTCTAC

# Sample Output:
# AAG -> AGA
# AGA -> GAT
# ATT -> TTC
# CTA -> TAC
# CTC -> TCT
# GAT -> ATT
# TCT -> CTA,CTC
# TTC -> TCT

use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

my $k = $data[0];
chomp $k;
my $string = $data[1];
chomp $string;

my @nodes;
for (my $i = 0; $i <= length($string) - ($k - 1); $i++) {
	push ( @nodes, substr($string, $i, ($k - 1)) );
}

my @output;
my $out;
my @mult;
my $skip = 0;

for ( my $j = 0; $j < scalar @nodes - 1; $j++ ) {
	# check if the $node[$j] has multiple out edges
	foreach ( @mult ) {
		if ( $_ eq $nodes[$j] ) {
			# if yes - skip it
			$skip = 1;
		}
	}
	# if not, perform the normal cycle
	if ( $skip != 1 ) {
		$out = $nodes[$j] . ' -> ' . $nodes[$j + 1];
		for (my $i = $j + 1; $i < scalar @nodes; $i++) {
			if ( $nodes[$i] eq $nodes[$j] ) {
				$out = $out . ',' . $nodes[$i + 1];
				push ( @mult, $nodes[$i] )
			}
		}
		push ( @output, $out );
	}
	$skip = 0;
}

@output = sort { $a cmp $b } @output;

open (F, '>output.txt');
print F join("\n", @output);
close F;

exit;

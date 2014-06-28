#!usr/bin/perl -w

# DeBruijn Graph from k-mers Problem: Construct the de Bruijn graph from a set of k-mers.
#      Input: A collection of k-mers Patterns.
#      Output: The adjacency list of the de Bruijn graph DeBruijn(Patterns).

# CODE CHALLENGE: Solve the de Bruijn Graph from k-mers Problem.

# Sample Input:
#      GAGG
#      GGGG
#      GGGA
#      CAGG
#      AGGG
#      GGAG

# Sample Output:
#      AGG -> GGG
#      CAG -> AGG
#      GAG -> AGG
#      GGA -> GAG
#      GGG -> GGA,GGG

use strict;
use warnings;
use List::MoreUtils qw/ uniq /;
use Data::Dumper;

# read the input file
open(F, 'input.txt');
my @kmers = <F>;
close F;
chomp @kmers;

sub Prefix {
	return ( substr ( $_[0], 0, length ( $_[0] ) - 1 ) );
}

sub Suffix {
	return ( substr ( $_[0], 1, length ( $_[0] ) - 1 ) );
}

my $out1;
my $out2;
my @prefixes;
my @suffixes;

# create @prefixes and @suffixes
foreach ( @kmers ) {
	push( @prefixes, &Prefix( $_ ) );
	push( @suffixes, &Suffix( $_ ) );
}

# create a matrix of unique k-1 mers using @prefixes and @suffixes
my @uniquek1mers = uniq ( @prefixes, @suffixes );
@uniquek1mers = sort { $a cmp $b } @uniquek1mers;
# initialize an adjacency matrix for @kmers
my @AdjacencyMatrix = map [(0) x scalar @uniquek1mers], 0..scalar @uniquek1mers - 1;

# index @prefixes and @suffixes by @uniquek1mers indexes
my @PrefInd = @prefixes;
my @SuffInd = @suffixes;

for ( my $i = 0; $i < scalar @uniquek1mers; $i++ ) {
	for ( my $j = 0; $j < scalar @kmers; $j++ ) {
		if ( $prefixes[$j] eq $uniquek1mers[$i] ) {
			$PrefInd[$j] = $i;
		}
		if ( $suffixes[$j] eq $uniquek1mers[$i] ) {
			$SuffInd[$j] = $i;
		}
	}
}

# fill in the adjacency matrix
for ( my $i = 0; $i < scalar @kmers; $i++ ) {
	$AdjacencyMatrix[$PrefInd[$i]][$SuffInd[$i]]+=1;
}

# print Dumper(\@AdjacencyMatrix);

# output De Bruijn graph using adjacency matrix
open (F, '>output.txt');

for ( my $i = 0; $i < scalar @uniquek1mers; $i++ ) {
	$out1 = $uniquek1mers[$i] . ' -> ';
	$out2 = '';
	for ( my $j = 0; $j < scalar @uniquek1mers; $j++ ) {
		if ( $AdjacencyMatrix[$i][$j] != 0 ) {
			$out2 = $out2 . $uniquek1mers[$j] . ',';
		}
	}
	if ( $out2 ne '' ) {
		chop $out2;
		print F $out1 . $out2 . "\n";
	}
}

close F;

exit;

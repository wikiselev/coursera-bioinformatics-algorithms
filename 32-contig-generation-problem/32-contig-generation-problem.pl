#!usr/bin/perl -w

# Contig Generation Problem: Generate the contigs from a collection of reads (with imperfect coverage).
#      Input: A collection of k-mers Patterns.
#      Output: All contigs in DeBruijn(Patterns).

# CODE CHALLENGE: Solve the Contig Generation Problem.

# Sample Input:
#      ATG
#      ATG
#      TGT
#      TGG
#      CAT
#      GGA
#      GAT
#      AGA

# Sample Output:
#      AGA ATG ATG CAT GAT TGGA TGT

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
print join("\n", @uniquek1mers);
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

print Dumper(\@AdjacencyMatrix);

my %nodes_ref;
my $i = 0;
foreach ( @uniquek1mers ) {
	$nodes_ref{$_} = $i;
	$i++;
}


my $sumRow = 0;
my $sumCol = 0;

for ( my $i = 0; $i < scalar values %nodes_ref; $i++ ) {
	$sumRow = eval join '+', @{$AdjacencyMatrix[$i]};
	for ( my $j = 0; $j < scalar values %nodes_ref; $j++ ) {
		$sumCol+=$AdjacencyMatrix[$j][$i];
	}
	if ( $sumCol == 0 | $sumCol > 1 | $sumRow > 1) {
		$unbalanced_col = $i;
	}
	$sumCol = 0;
}
print $unbalanced_row . $unbalanced_col . "\n";
$AdjacencyMatrix[$unbalanced_row][$unbalanced_col]++;


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

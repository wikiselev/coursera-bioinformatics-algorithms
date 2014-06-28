#!usr/bin/perl -w

# CODE CHALLENGE: Solve the String Reconstruction from Read-Pairs Problem.
#      Input: An integer d followed by a collection of paired k-mers PairedReads.
#      Output: A string Text with (k, d)-mer composition equal to PairedReads.

# Sample Input:
#      2
#      GAGA|TTGA
#      TCGT|GATG
#      CGTG|ATGT
#      TGGT|TGAG
#      GTGA|TGTT
#      GTGG|GTGA
#      TGAG|GTTG
#      GGTC|GAGA
#      GTCG|AGAT

# Sample Output:
#      GTGGTCGTGAGATGTTGA

use strict;
use warnings;
use List::MoreUtils qw/ uniq /;
use List::MoreUtils qw(firstidx);
use Storable qw(dclone);
use Data::Dumper;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;
my $d = $data[0];
chomp $d;
# initialize k-mers
my @kmers = @data[1 .. scalar @data - 1];
chomp @kmers;


sub Prefix {
	my @pair = split (/\|/, $_[0]);
	# print join("\n", @pair);
	# print "\n";
	my $pref1 = substr ( $pair[0], 0, length ( $pair[0] ) - 1 );
	my $pref2 = substr ( $pair[1], 0, length ( $pair[1] ) - 1 );
	return ( $pref1 . "\|" . $pref2 );
}

sub Suffix {
	my @pair = split (/\|/, $_[0]);
	# print join("\n", @pair);
	# print "\n";
	my $suf1 = substr ( $pair[0], 1, length ( $pair[0] ) - 1 );
	my $suf2 = substr ( $pair[1], 1, length ( $pair[1] ) - 1 );
	return ( $suf1 . "\|" . $suf2 );
}

my @uniquek1mers;
my @AdjacencyMatrix;
my $cycle_len = 0;

sub DeBruijnFromKmers {
	my @kmers = @{ dclone($_[0]) };
	my @prefixes;
	my @suffixes;
	# create @prefixes and @suffixes
	foreach ( @kmers ) {
		push( @prefixes, &Prefix( $_ ) );
		push( @suffixes, &Suffix( $_ ) );
	}


	# create a matrix of unique k-1 mers using @prefixes and @suffixes
	@uniquek1mers = uniq ( @prefixes, @suffixes );
	@uniquek1mers = sort { $a cmp $b } @uniquek1mers;
	# print join("\n", @uniquek1mers);
	# print "\n";
	# initialize an adjacency matrix for @kmers
	@AdjacencyMatrix = map [(0) x scalar @uniquek1mers], 0..scalar @uniquek1mers - 1;

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

	# print join(' ', @PrefInd);
	# print "\n";
	# print join(' ', @SuffInd);
	# print "\n";


	# fill in the adjacency matrix
	for ( my $i = 0; $i < scalar @kmers; $i++ ) {
		$AdjacencyMatrix[$PrefInd[$i]][$SuffInd[$i]]+=1;
		$cycle_len++;
	}
	# print Dumper(\@AdjacencyMatrix);
	# print $cycle_len . "\n";

}


# print join("\n", @kmers);
# print "\n" . "\n";

&DeBruijnFromKmers(\@kmers);

# create a hash which index all the nodes from 0 to their total number
my %nodes_ref;
my $i = 0;
foreach ( @uniquek1mers ) {
	$nodes_ref{$_} = $i;
	$i++;
}


# my $out1;
# my $out2;

# for ( my $i = 0; $i < scalar @uniquek1mers; $i++ ) {
# 	$out1 = $uniquek1mers[$i] . ' -> ';
# 	$out2 = '';
# 	for ( my $j = 0; $j < scalar @uniquek1mers; $j++ ) {
# 		if ( $AdjacencyMatrix[$i][$j] != 0 ) {
# 			$out2 = $out2 . $uniquek1mers[$j] . ',';
# 		}
# 	}
# 	if ( $out2 ne '' ) {
# 		chop $out2;
# 		print $out1 . $out2 . "\n";
# 	}
# }

# print Dumper(\@AdjacencyMatrix);


# add an extra node to the graph to balance it to be able to find an Euler cycle
# for the graph to be balanced sumCol and sumRow for each index in AdjacencyMatrix
# must be the same

my $sumRow = 0;
my $sumCol = 0;
my $unbalanced_row;
my $unbalanced_col;

for ( my $i = 0; $i < scalar values %nodes_ref; $i++ ) {
	$sumRow = eval join '+', @{$AdjacencyMatrix[$i]};
	for ( my $j = 0; $j < scalar values %nodes_ref; $j++ ) {
		$sumCol+=$AdjacencyMatrix[$j][$i];
	}
	if ( $sumRow > $sumCol ) {
		$unbalanced_col = $i;
	}
	if ( $sumRow < $sumCol ) {
		$unbalanced_row = $i;
	}
	$sumCol = 0;
}
# print $unbalanced_row . $unbalanced_col . "\n";
$AdjacencyMatrix[$unbalanced_row][$unbalanced_col]++;

$cycle_len++;
$cycle_len++;

sub Cycle {
	my $node1 = $_[0];
	my $node2 = 1;
	my @cycle = ($node1);
	while ( $node2 != -1 ) {
		$node2 = firstidx { $_ > 0 } @{$AdjacencyMatrix[$node1]};
		if ( $node2 >= 0 ) {
			$AdjacencyMatrix[$node1][$node2] -= 1;
			push ( @cycle, $node2 );
			$node1 = $node2;
		}
	}
	return @cycle;
}

# print &Cycle(3);

my @cycle;
my $newStart;
my $ind;

# this a cool cycle - it goes through adjacency matrix only once!!!

# form a cycle Cycle by randomly walking in Graph (never visit an edge twice!)
@cycle = &Cycle($unbalanced_col);
# print Dumper(\@AdjacencyMatrix);

# print join("\n", @kmers);
# print "\n";

# print join("\n", @uniquek1mers);
# print "\n";

# print @cycle;
# print "\n";

# print scalar @cycle;
# print "\n";
# print $cycle_len;
# print "\n";


# while there are unexplored edges
while ( scalar @cycle != $cycle_len ) {
	# print "test" . "\n";
	# print scalar @cycle;
	# print "\n";

	# select a node newStart in Cycle with still unexplored edges
	foreach ( @cycle ) {
		$ind = firstidx { $_ > 0 } @{$AdjacencyMatrix[$_]};
		if ( $ind >= 0 ) {
			$newStart = $_;
			last;
		}
	}

	# traversing Cycle (starting at newStart)
	# pop ( @cycle );
	# while ( $cycle[0] != $newStart ) {
	# 	push(@cycle, shift(@cycle));
	# }

	# form Cycle’ by traversing Cycle (starting at newStart) and randomly walking
	@cycle = (@cycle, &Cycle($newStart));
}

# pop ( @cycle );

# # move the cycle, so that it starts with unbalanced_col
pop ( @cycle );
while ( $cycle[0] != $unbalanced_col ) {
	push(@cycle, shift(@cycle));
}

# revert the index back to original node values
my %rhash = reverse %nodes_ref;
foreach ( @cycle ) {
	$_ = $rhash{$_};
}

my @pair = split (/\|/, $cycle[0]);
my $str1 = substr ( $pair[0], 0, length ( $pair[0] ) - 2 );
my $str2;

# connect all the nodes into one string
for ( my $i = length ( $pair[0] ) - 2; $i < scalar @cycle - 1; $i++ ) {
	@pair = split (/\|/, $cycle[$i]);
	$str1 = $str1 . substr ( $pair[0], 0, 1 );
	$str2 = $str2 . substr ( $pair[1], 0, 1 );
	# $cycle[$i] = substr ( $cycle[$i], length ($cycle[$i]) - 1, 1 );	
}

@pair = split (/\|/, $cycle[scalar @cycle - 1]);

$str2 = $str2 . substr ( $pair[1], 0, length( $pair[1] ) );

$str2 = substr ( $str2, - $d - 2*length( $pair[1] ) - 1 );

open (F, '>output.txt');
print F $str1 . $str2;
print F "\n";
close F;


exit;

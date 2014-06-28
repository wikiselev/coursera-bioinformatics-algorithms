#!usr/bin/perl -w

# CODE CHALLENGE: Solve the k-Universal Circular String Problem.
#      Input: An integer k.
#      Output: A k-universal circular string.

# Sample Input:
#      4

# Sample Output:
#      0000110010111101

use strict;
use warnings;
use List::MoreUtils qw/ uniq /;
use List::MoreUtils qw(firstidx);
use Storable qw(dclone);
use Data::Dumper;

# read the input file
open(F, 'input.txt');
my $k = <F>;
close F;
chomp $k;

sub InitializeKmers {
	my @list = @_;
	my $k = $list[0];
	my @bases = ('0', '1');
	my @words = @bases;

	for my $i (1..$k-1)
	{
		undef my @newwords;
		foreach my $w (@words)
		{
			foreach my $b (@bases)
			{
				push (@newwords,$w.$b);
			}
		}
		undef @words;
		@words = @newwords;
	}
	return @words;
}

sub Prefix {
	return ( substr ( $_[0], 0, length ( $_[0] ) - 1 ) );
}

sub Suffix {
	return ( substr ( $_[0], 1, length ( $_[0] ) - 1 ) );
}

my @uniquek1mers;

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

	# initialize an adjacency matrix for @kmers
	my %DeBruijnGraph;

	# fill in the adjacency matrix
	for ( my $i = 0; $i < scalar @uniquek1mers; $i++ ) {
		for ( my $j = 0; $j < scalar @uniquek1mers; $j++ ) {
			if ( &Suffix( $uniquek1mers[$i] ) eq &Prefix( $uniquek1mers[$j] ) ) {
				$DeBruijnGraph{$i} = $j;
			}
		}
	}

	return %DeBruijnGraph;
}


# initialize k-mers
my @kmers = &InitializeKmers($k);

# print join("\n", @kmers);
# print "\n" . "\n";

# create a De Bruijn graph from all k-mers
my %DeBruijnGraph = &DeBruijnFromKmers(\@kmers);
# open (F, '>output.txt');
# print Dumper(\@DeBruijnGraph);
# close F;

print join(" ", keys %DeBruijnGraph);
print "\n";
print join(" ", values %DeBruijnGraph);
print "\n";

# sub Cycle {
# 	my $node1 = $_[0];
# 	my $node2 = 1;
# 	my @cycle = ($node1);
# 	while ( $node2 != -1 ) {
# 		$node2 = firstidx { $_ > 0 } @{$AdjacencyMatrix[$node1]};
# 		if ( $node2 >= 0 ) {
# 			$AdjacencyMatrix[$node1][$node2] -= 1;
# 			push ( @cycle, $node2 );
# 			$node1 = $node2;
# 		}
# 	}
# 	return @cycle;
# }

# sub EulerianCycle {
# 	my @nodes_ref = @{ dclone(\@uniquek1mers) };
# 	my $cycle_len = 0;


# 	# create a hash which index all the nodes from 0 to their total number
# 	my %nodes_ref;
# 	my $i = 0;
# 	foreach ( @nodes_ref ) {
# 		$nodes_ref{$_} = $i;
# 		$i++;
# 	}

# 	# populate the adjacency matrix
# 	$cycle_len = 2 ** $k + 1;

# 	my @cycle;
# 	my $newStart;
# 	my $ind;

# 	# this a cool cycle - it goes through adjacency matrix only once!!!

# 	# form a cycle Cycle by randomly walking in Graph (never visit an edge twice!)
# 	@cycle = &Cycle(0);

# 	# print join("\n", @cycle);
# 	# print "\n";
# 	# print "\n";

# 	# print scalar @cycle;
# 	# print "\n";
# 	# print $cycle_len . "\n";
# 	# print join("\n", @cycle);
# 	# print "\n";
# 	# while there are unexplored edges
# 	while ( scalar @cycle != $cycle_len ) {
# 		# print "test" . "\n";
# 		# print "\n";
# 		# print Dumper(\@AdjacencyMatrix);
# 		# select a node newStart in Cycle with still unexplored edges
# 		foreach ( @cycle ) {
# 			$ind = firstidx { $_ > 0 } @{$AdjacencyMatrix[$_]};
# 			if ( $ind >= 0 ) {
# 				$newStart = $_;
# 				last;
# 			}
# 		}

# 		# traversing Cycle (starting at newStart)
# 		pop ( @cycle );
# 		while ( $cycle[0] != $newStart ) {
# 			push(@cycle, shift(@cycle));
# 		}

# 		# form Cycle’ by traversing Cycle (starting at newStart) and randomly walking
# 		@cycle = (@cycle, &Cycle($newStart));
# 		print join("\n", @cycle);
# 		print "\n";
# 		print "\n";
# 	}

# 	pop ( @cycle );
# 	# pop ( @cycle );

# 	# move the cycle, so that it starts with unbalanced_col
# 	# pop ( @cycle );

# 	# while ( $cycle[0] != $unbalanced_col ) {
# 	# 	push(@cycle, shift(@cycle));
# 	# }

# 	# revert the index back to original node values
# 	my %rhash = reverse %nodes_ref;
# 	foreach ( @cycle ) {
# 		$_ = $rhash{$_};
# 	}

# 	print join("\n", @cycle);
# 	print "\n";
# 	print "\n";

# 	# print join("\n", @cycle);
# 	# print "\n";
# 	# connect all the nodes into one string
# 	for ( my $i = 0; $i < scalar @cycle; $i++ ) {
# 		$cycle[$i] = substr ( $cycle[$i], length ($cycle[$i]) - 1, 1 );	
# 	}

# 	return @cycle;
# 	# print Dumper(\@AdjacencyMatrix);
# }

# # find an Eulerian cycle in AdjacencyMatrix graph
# my @cycle = &EulerianCycle;

# open (F, '>output.txt');
# print F join('', @cycle);
# print F "\n";
# close F;

exit;

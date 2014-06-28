#!usr/bin/perl -w

# CODE CHALLENGE: Solve the Eulerian Cycle Problem.
#      Input: The adjacency list of an Eulerian directed graph.
#      Output: An Eulerian cycle in this graph.

# Sample Input:
#      0 -> 3
#      1 -> 0
#      2 -> 1,6
#      3 -> 2
#      4 -> 2
#      5 -> 4
#      6 -> 5,8
#      7 -> 9
#      8 -> 7
#      9 -> 6

# Sample Output:
#      6->8->7->9->6->5->4->2->1->0->3->2->6

use strict;
use warnings;
use List::MoreUtils qw/ uniq /;
use List::MoreUtils qw(firstidx);
use Storable qw(dclone);
use Data::Dumper;

# read the input file
open(F, 'input.txt');
my @kmers = <F>;
close F;
chomp @kmers;

# initialize an adjacency matrix
my @AdjacencyMatrix = map [(0) x scalar @kmers], 0..scalar @kmers - 1;

my @edges;
my @edges_ref;
my $edge_out;
my @edge_in;
my $i = 0;
my $cycle_len = 0;

# populate the adjacency matrix
foreach ( @kmers ) {
	@edges = split ( ' -> ', $_ );
	$edge_out = $edges[0];
	push( @edges_ref, $edge_out );
	@edge_in = split ( ',', $edges[1] );
	foreach ( @edge_in ) {
		$AdjacencyMatrix[$edge_out][$_]+=1;
		$cycle_len++;
	}
}
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

my @cycle;
my $newStart;
my $ind;

# this a cool cycle - it goes through adjacency matrix only once!!!

# form a cycle Cycle by randomly walking in Graph (never visit an edge twice!)
@cycle = &Cycle(0);

# while there are unexplored edges
while ( scalar @cycle != $cycle_len ) {

	# select a node newStart in Cycle with still unexplored edges
	foreach ( @cycle ) {
		$ind = firstidx { $_ > 0 } @{$AdjacencyMatrix[$_]};
		if ( $ind >= 0 ) {
			$newStart = $_;
			last;
		}
	}

	# traversing Cycle (starting at newStart)
	pop ( @cycle );
	while ( $cycle[0] != $newStart ) {
		push(@cycle, shift(@cycle));
	}

	# form Cycle’ by traversing Cycle (starting at newStart) and randomly walking
	@cycle = (@cycle, &Cycle($newStart));
}

open (F, '>output.txt');
print F join('->', @cycle);
print F "\n";
close F;

# print Dumper(\@AdjacencyMatrix);

exit;

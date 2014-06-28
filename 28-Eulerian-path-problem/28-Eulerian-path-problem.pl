#!usr/bin/perl -w

# CODE CHALLENGE: Solve the Eulerian Path Problem.
#      Input: The adjacency list of a directed graph that has an Eulerian path.
#      Output: An Eulerian path in this graph.

# Sample Input:
#      0 -> 2
#      1 -> 3
#      2 -> 1
#      3 -> 0,4
#      6 -> 3,7
#      7 -> 8
#      8 -> 9
#      9 -> 6

# Sample Output:
#      6->7->8->9->6->3->0->2->1->3->4

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

# here there is one extra step compared to Eulerian cycle - first I need to
# balance all the nodes. I will do that using adjacency matrix.

my @nodes;
my @nodes_ref;
my $node_out;
my @node_in;
my $cycle_len = 0;

# get all possible nodes in the graph
foreach ( @kmers ) {
	@nodes = split ( ' -> ', $_ );
	$node_out = $nodes[0];
	push( @nodes_ref, $node_out );
	@node_in = split ( ',', $nodes[1] );
	push( @nodes_ref, @node_in );
}

# exclude duplicated nodes and sort them
@nodes_ref = uniq @nodes_ref;
@nodes_ref = sort {$a <=> $b} @nodes_ref;

# create a hash which index all the nodes from 0 to their total number
my %nodes_ref;
my $i = 0;
foreach ( @nodes_ref ) {
	$nodes_ref{$_} = $i;
	$i++;
}

# initialize an adjacency matrix
my @AdjacencyMatrix = map [(0) x scalar @nodes_ref], 0..scalar @nodes_ref - 1;

# populate the adjacency matrix
foreach ( @kmers ) {
	@nodes = split ( ' -> ', $_ );
	$node_out = $nodes[0];
	push( @nodes_ref, $node_out );
	@node_in = split ( ',', $nodes[1] );
	foreach ( @node_in ) {
		$AdjacencyMatrix[$nodes_ref{$node_out}][$nodes_ref{$_}]+=1;
		$cycle_len++;
	}
}
$cycle_len++;
# I need this one because I will add one more edge to the graph
$cycle_len++;

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
print $unbalanced_row . $unbalanced_col . "\n";
$AdjacencyMatrix[$unbalanced_row][$unbalanced_col]++;

# print Dumper(\@AdjacencyMatrix);
# print $unbalanced_row . $unbalanced_col . "\n";
# print join(" ", @unbalanced_nodes);

# print $cycle_len;
# print "\n";

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
@cycle = &Cycle(0);

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
	pop ( @cycle );
	while ( $cycle[0] != $newStart ) {
		push(@cycle, shift(@cycle));
	}

	# form Cycle’ by traversing Cycle (starting at newStart) and randomly walking
	@cycle = (@cycle, &Cycle($newStart));
}

# pop ( @cycle );

# move the cycle, so that it starts with unbalanced_col
pop ( @cycle );
while ( $cycle[0] != $unbalanced_col ) {
	push(@cycle, shift(@cycle));
}

# revert the index back to original node values
my %rhash = reverse %nodes_ref;
foreach ( @cycle ) {
	$_ = $rhash{$_};
}

open (F, '>output.txt');
print F join('->', @cycle);
print F "\n";
close F;

# print Dumper(\@AdjacencyMatrix);

exit;

#!usr/bin/perl -w

# Pattern Matching Problem: Find all occurrences of a pattern in a string.
#      Input: Two strings: Pattern and Genome.
#      Output: All starting positions where Pattern appears as a substring of Genome.

# Sample Input:
#      ATAT
#      GATATATGCATATACTT

# Sample Output:
#      1 3 9

# read the input
open(F, 'input.txt');
my @data = <F>;
close F;

# assign variables to the input data
my $pattern = $data[0];
my $genome = $data[1];
my $offset = 0;

# remove end of line characters
chomp($pattern);
chomp($genome);

# find a position of the first appearance of $pattern in $genome
my $result = index($genome, $pattern, $offset);

# find other positions where $pattern appears in $genome
while ($result != -1) {
	# print the results
	print "$result ";
	# this will move the search to the next appearance
	$offset = $result + 1;
	$result = index($genome, $pattern, $offset);
}

print "\n";

exit;

#!usr/bin/perl -w

# Approximate Pattern Matching Problem: Find all approximate occurrences of a pattern in a string.
#      Input: Two strings Pattern and Text along with an integer d.
#      Output: All positions where Pattern appears in Text with at most d mismatches.

# Sample Input:
#      ATTCTGGA
#      CGCCCGAATCCAGAACGCATTCCCATATTTCGGGACCACTGGCCTCCACGGTACGGACGTCAATCAAAT
#      3

# Sample Output:
#      6 7 26 27

use List::Util qw( min max );

# read the input
open(F, 'input.txt');
my @data = <F>;
close F;

# assign variables to the input data
my $genome = $data[0];

# remove end of line characters
chomp($genome);

# initialize variables
my $char;
my $tmp = 0;
my @skew;
$skew[0] = 0;

# split $genome into #chars
my @chars = split("", $genome);

# for each next letter in the genome either add or subtract 1 from $tmp --
# this is equal to #G-#C in the string including all chars up to the current one
foreach (@chars) {
	if ($_ eq 'G') {
		$tmp++;
	} 
	if ($_ eq 'C') {
		$tmp--;
	}

	# add the $tmp value to @skew
	push (@skew, $tmp);
}

# find indexes of the minimum elements of @skew
my @ind = grep { $skew[$_] == min @skew } 0 .. $#skew;

# print the results
print join(' ', @ind);
print "\n";

exit;

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

# read the input
open(F, 'input.txt');
my @data = <F>;
close F;

# assign variables to the input data
my $pattern = $data[0];
my $genome = $data[1];
my $mismnum = $data[2];

# remove end of line characters
chomp($pattern);
chomp($genome);

# initialize variables
my @pat = split '', $pattern;
my $string;
my @str;
my @positions;
my @mismatch;
my $res;

# go through the $genome string
for ($i = 0; $i <= (length($genome) - length($pattern)); $i++) {
	# for each position in the genome define the substring
	$string = substr($genome, $i, length($pattern));
	@str = split '', $string;
	# find the number of mismatches between $string and initial $pattern
	@mismatch = map { if ( $pat[$_] ne $str[$_] ) {$_} } 0 .. $#str;
	$res = join('', @mismatch);
	# if there are less then $mismnum mismatches between them save the position
	# of the $string in the $genome
	if ( length($res) <=  $mismnum ) {
		push (@positions, $i);
	}
}

# print the results
print join ' ', @positions;

print "\n";

exit;

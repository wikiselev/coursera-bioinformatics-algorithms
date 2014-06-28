#!usr/bin/perl -w

# Frequent Words Problem: Find the most frequent k-mers in a string.
#      Input: A string Text and an integer k.
#      Output: All most frequent k-mers in Text.

# Sample Input:
#      ACGTTGCATGTCGCATGATGCATGAGAGCT
#      4

# Sample Output:
#      CATG GCAT

use List::Util qw( min max );

# read the input
open(F, 'input.txt');
my @data = <F>;
close F;

# assign variables to the input data
my $string = $data[0];
my $k = $data[1];
my @motifs;

# save all the k-mers that appear in the input string into the @motifs array
for ($i = 0; $i <= (length($string) - $k - 1); $i++) {
	push (@motifs, substr($string, $i, $k));
}

# make hash for @motifs and calculate the frequency of each motif appearance
my %seen;
foreach ( @motifs ) { 
    $seen{$_}++;
}

# save the maximum frequency of the motif appearance
my $max_freq = max values %seen;

# access the hash by the value of $max_freq and save all motifs that correspond
# to the $max_freq
my @keys = grep { $seen{$_} == $max_freq } keys %seen;

# print the found motifs
print join( ' ', @keys );
print "\n";

exit;

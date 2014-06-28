#!usr/bin/perl -w

# Frequent Words with Mismatches Problem: Find the most frequent k-mers with mismatches in a string.
#      Input: A string Text as well as integers k and d. (You may assume k ≤ 12 and d ≤ 3.)
#      Output: All most frequent k-mers with up to d mismatches in Text.

# Sample Input:
#      ACGTTGCATGTCGCATGATGCATGAGAGCT 4 1
# Sample Output:
#      GATG ATGC ATGT

use List::Util qw( min max );

# read the input
open(F, 'input.txt');
my @data = <F>;
close F;

# assign variables to the input data
my $dat = $data[0];
chomp($dat);
my @dat = split(' ', $dat);
my $genome = $dat[0];
my $k = $dat[1];
my $d = $dat[2];

# taken from http://www.bioperl.org/wiki/Getting_all_k-mer_combinations_of_residues
sub InitializeAllKmers {
	my @list = @_;
	my $k = $list[0];
	@bases = ('A','C','G','T');
	@words = @bases;

	for $i (1..$k-1)
	{
		undef @newwords;
		foreach $w (@words)
		{
			foreach $b (@bases)
			{
				push (@newwords,$w.$b);
			}
		}
		undef @words;
		@words = @newwords;
	}
	return @words;
}

# Hamming's distance
# taken from http://stackoverflow.com/questions/8459585/how-do-i-make-inexact-string-comparisons-with-perl
sub hd{ length( $_[ 0 ] ) - ( ( $_[ 0 ] ^ $_[ 1 ] ) =~ tr[\0][\0] ) }

my @motifs;
my $motif;
my $kmer;

my @kmers = &InitializeAllKmers($k);
my %mismatches;
foreach ( @kmers ) { 
    $mismatches{$_} = 0;
}

# save all the k-mers that appear in the input string into the @motifs array
for ($i = 0; $i <= (length($genome) - $k); $i++) {
	push (@motifs, substr($genome, $i, $k));
}

# idea is taken from here:
# http://stackoverflow.com/questions/19941079/inverse-of-hamming-distance
# go through all motifs and for each of them find all @kmers that are $d distant
# from a given motif and increment those kmers by 1
foreach my $motif ( @motifs ) {
	foreach my $kmer ( @kmers ) {
		if ( &hd($motif, $kmer) <= $d ) {
			$mismatches{$kmer}++;
		}
	}
}

# save the maximum frequency of the kmers appearance
my $max_freq = max values %mismatches;

# access the hash by the value of $max_freq and save all kmers that correspond
# to the $max_freq
my @keys = grep { $mismatches{$_} == $max_freq } keys %mismatches;

# print the found kmers
print join( ' ', @keys );
print "\n";

exit;

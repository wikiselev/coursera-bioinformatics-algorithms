#!usr/bin/perl -w

# Input: An integer k, followed by a collection of strings Dna.

# Output: A k-mer Pattern that minimizes d(Pattern, Dna) among all k-mers Pattern.

# MEDIANSTRING(Dna, k)
# BestPattern ← AAA…AA
# for each k-mer Pattern from AAA…AA to TTT…TT
#     if d(Pattern, Dna) < d(BestPattern, Dna)
#          BestPattern ← Pattern
# output BestPattern

# Sample Input:
# 3
# AAATTGACGCAT
# GACGACCACGTT
# CGTCAGCGCCTG
# GCTGAGCACCGG
# AGTACGGGACAG

# Sample Output:
# GAC

use List::MoreUtils qw/ uniq /;
use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

my $k = $data[0];
chomp $k;

my @Dna = @data[1 .. scalar @data - 1];
chomp(@Dna);

# Hamming's distance
# taken from http://stackoverflow.com/questions/8459585/how-do-i-make-inexact-string-comparisons-with-perl
sub hd{ length( $_[ 0 ] ) - ( ( $_[ 0 ] ^ $_[ 1 ] ) =~ tr[\0][\0] ) }

# taken from http://www.bioperl.org/wiki/Getting_all_k-mer_combinations_of_residues
sub InitializeAllKmers {
	my @list = @_;
	my $k = $list[0];
	my @bases = ('A','C','G','T');
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

sub d {
	my $Pattern = $_[0];
	my $hd;
	my $hd_tmp;
	my $score = 0;

	# save all the k-mers that appear in @Dna into the @motifs array
	foreach my $string (@Dna) {
		$hd = length $Pattern;
		for (my $i = 0; $i <= (length($string) - length($Pattern)); $i++) {
			$hd_tmp = &hd( substr($string, $i, $k), $Pattern );
			if ( $hd_tmp < $hd ) {
				$hd = $hd_tmp;
			}
		}
		$score = $score + $hd;
	}
	return ( $score );
}


# initialize all possible k-mers
my @kmers = &InitializeAllKmers($k);

my $BestPattern;
my $d_best = 10000000;
my $d;

foreach my $kmer ( @kmers ) {
	$d = &d( $kmer );
	if ( $d < $d_best ) {
		$BestPattern = $kmer;
		$d_best = $d;
	}
}

print $BestPattern;
print "\n";

exit;

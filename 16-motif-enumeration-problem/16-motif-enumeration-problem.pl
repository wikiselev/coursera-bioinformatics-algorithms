#!usr/bin/perl -w

# Input: Integers k and d, followed by a collection of strings Dna.

# Output: All (k, d)-motifs in Dna.

# MOTIFENUMERATION(Dna, k, d)
# for each k-mer a in Dna
#     for each k-mer a’ differing from a by at most d mutations
#         if a’ appears in each string from Dna with at most d mutations
#             output a’

# Sample Input:
#      3 1
#      ATTTGGC
#      TGCCTTA
#      CGGTATC
#      GAAAATT

# Sample Output:
#      ATA ATT GTT TTT

use List::MoreUtils qw/ uniq /;
use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

my $param = $data[0];
chomp($param);
my @param = split(' ', $param);
my $k = $param[0];
my $d = $param[1];

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

my @motifs;

# save all the k-mers that appear in @Dna into the @motifs array
foreach my $string (@Dna) {
	for (my $i = 0; $i <= (length($string) - $k); $i++) {
		push (@motifs, substr($string, $i, $k));
	}
}

# initialize all possible k-mers
my @kmers = &InitializeAllKmers($k);

my $i;
my $j;
my $i_node;
my @result;

foreach my $motif ( @motifs ) {
	foreach my $kmer ( @kmers ) {
		if ( &hd( $kmer, $motif ) <= $d ) {
			$i = 0;
			foreach my $string (@Dna) {
				$i_node = $i;
				$j = 0;
				for (my $l = 0; $l <= (length($string) - $k); $l++) {
					if ( &hd( substr($string, $l, $k), $kmer ) <= $d ) {
						$j++;
					}
				}
				if ( $j > 0 ) {
					$i++;
				} else {
					last;
				}
				if ( $i == $i_node ) {
					last;
				}
			}
			if ( $i >= scalar @Dna ) {
				push( @result, $kmer );
			}
		}
	}
}

print join (' ', uniq @result);
print "\n";

exit;

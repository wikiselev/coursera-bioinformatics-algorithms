#!usr/bin/perl -w

# Peptide Encoding Problem: Find substrings of a genome encoding a given amino acid sequence.
#      Input: A DNA string Text and an amino acid string Peptide.
#      Output: All substrings of Text encoding Peptide (if any such substrings exist).

# Sample Input:
#      ATGGCCATGGCCCCCAGAACTGAGATCAATAGTACCCGTATTAACGGGTGA
#      MA

# Sample Output:
#      ATGGCC
#      GGCCAT
#      ATGGCC

use List::Util 'max';

# import codon table into a hash
open(F, 'codon-table.txt');
my @codonsTab = <F>;
close F;

chomp(@codonsTab);
my %codons = ();
foreach (@codonsTab) {
	@line = split(' ', $_);
	if ($line[0] eq "UAA" | $line[0] eq "UAG" | $line[0] eq "UGA") {
		$codons{$line[0]} = '';
	} else {
		$codons{$line[0]} = $line[1];
	}
}

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

my $rna = $data[0];
my $prot = $data[1];
chomp($rna);
chomp($prot);

# split $prot in aminoacids
@aminoacids = split('', $prot);

my @motifs = ();
my @motifs1 = ('');
my @motifs2 = ('');

# translate back each amino acid into a set of rna triplets using %codons hash
foreach my $aa (@aminoacids) {
	@motifs2 = grep { $codons{$_} eq $aa } keys %codons;
	foreach my $m2 (@motifs2) {
		foreach my $m1 (@motifs1) {
			push (@motifs, $m1 . $m2);
		}
	}
	@motifs1 = @motifs;
	@motifs = ();
}

@motifs = @motif1;

print join("\n", @motifs);

# assign variables to the input data
my $k = length($prot)*3;
my @peptides;

# save all the k-mers that appear in the input rna into the @motifs array
for ($i = 0; $i <= (length($rna) - $k - 1); $i++) {
	foreach my $m (@motifs){
		$p = substr($rna, $i, $k);
		if( $m == $p ) {
			push (@peptides, substr($rna, $i, $k));
		}
	}
}

exit;

#!usr/bin/perl -w

# Protein Translation Problem: Translate an RNA string into an amino acid string.
#      Input: An RNA string Pattern.
#      Output: The translation of Pattern into an amino acid string Peptide.

# Sample Input:
#      AUGGCCAUGGCGCCCAGAACUGAGAUCAAUAGUACCCGUAUUAACGGGUGA

# Sample Output:
#      MAMAPRTEINSTRING

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

# split $rna in triplets
@array = ( $rna =~ m/.../g );

# translate each nucleotide triplet into amino acid using %codons hash
foreach (@array) {
	$_ = $codons{$_};
}

print @array;
print "\n";

exit;

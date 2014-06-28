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

# assign variables to the input data
my $k = length($prot)*3;
my @peptides;
my @array1 = ();
my @array2 = ();
my @tmp = ();

# save all the k-mers that appear in the input rna into the @motifs array
for ($i = 0; $i <= (length($rna) - $k); $i++) {
	$pep = substr($rna, $i, $k);
	$p = $pep;
	# transcribe DNA to RNA
	$p =~ tr/T/U/;
	# split RNA in triplets
	@array = ( $p =~ m/.../g );

	# translate each nucleotide triplet into amino acid using %codons hash
	foreach (@array) {
		$_ = $codons{$_};
	}

	$p1 =  join('', @array);

	$p_c = $pep;
	# complement the string
	$p_c =~ tr/ACGT/TGCA/;
	# reverse the string
	$p_c = reverse $p_c;
	# transcribe DNA to RNA
	$p_c =~ tr/T/U/;
	@array = ( $p_c =~ m/.../g );

	# translate each nucleotide triplet into amino acid using %codons hash
	foreach (@array) {
		$_ = $codons{$_};
	}
	$p2 =  join('', @array);
	if( $p1 eq $prot | $p2 eq $prot) {
		push (@peptides, $pep);
	}
}

print join("\n", @peptides);
print "\n";

exit;

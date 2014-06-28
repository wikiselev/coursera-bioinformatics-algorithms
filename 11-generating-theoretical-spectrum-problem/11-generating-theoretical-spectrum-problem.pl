#!usr/bin/perl -w

# Generating Theoretical Spectrum Problem: Generate the theoretical spectrum of a cyclic peptide.
#      Input: An amino acid string Peptide.
#      Output: Cyclospectrum(Peptide).

# Sample Input:
#      LEQN

# Sample Output:
#      0 113 114 128 129 227 242 242 257 355 356 370 371 484

use List::Util 'max';

# import codon table into a hash
open(F, 'amino-acid-mol-mass.txt');
my @molMassTab = <F>;
close F;

chomp(@molMassTab);
my %molMass = ();
foreach (@molMassTab) {
	@line = split(' ', $_);
	$molMass{$line[0]} = $line[1];
}

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

my $prot = $data[0];
chomp($prot);

# make the peptide cyclic
$prot1 = $prot . $prot;

my @peps;

# record all sub cyclopeptides to @peps
for(my $width = 1; $width < length($prot); $width++) {
	for(my $pos = 0; $pos < length($prot); $pos++) {
		push(@peps, substr($prot1, $pos, $width));
	}
}

push(@peps, $prot);

# calculate and print masses of all sub cyclopeptides
print "0 "; 
my $mass = 0;
foreach (@peps) {
	foreach(split('', $_)) {
		$mass = $mass + $molMass{$_};
	}
	print $mass . " ";
	$mass = 0;
}
print "\n";
exit;

#!usr/bin/perl -w

# Profile-most Probable k-mer Problem: Find a Profile-most probable k-mer in a string.
# Input: A string Text, an integer k, and a k × 4 matrix Profile.
# Output: A Profile-most probable k-mer in Text.

# Sample Input:
# ACCTGTTTATTGCCTAAGTTCCGAACAAACCCAATATAGCCCGAGGGCCT
# 5
# A C G T
# 0.2 0.4 0.3 0.1
# 0.2 0.3 0.3 0.2
# 0.3 0.1 0.5 0.1
# 0.2 0.5 0.2 0.1
# 0.3 0.1 0.4 0.2

# Sample Output:
# CCGAG

use List::MoreUtils qw/ uniq /;
use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

my $Text = $data[0];
chomp $Text;

my $k = $data[1];
chomp $k;

my $Alphabet = $data[2];
chomp $Alphabet;
my @Alphabet = split(' ', $Alphabet);

my @Profile = @data[3 .. scalar @data - 1];
chomp(@Profile);

my %Profile;
my @str;
my $i;

foreach my $str (@Profile) {
	@str = split(' ', $str);
	$i = 0;
	foreach my $let (@Alphabet) {
		push(@{$Profile{$let}}, $str[$i]);
		$i++;
	}
}

sub Probability {
	my $i = 0;
	my $P = 1;
	foreach (split('', $_[0])){
		$P = $P*@{$Profile{$_}}[$i];
		$i++;
	}
	return($P);
}

my $kmer;
my $most_prob_kmer = substr($Text, 0, $k);
my $P;
my $largest_P = &Probability($most_prob_kmer);

for (my $i = 0; $i <= (length($Text) - $k); $i++) {
	$kmer = substr($Text, $i, $k);
	$P = &Probability($kmer);
	if ( $P > $largest_P ) {
		$most_prob_kmer = $kmer;
		$largest_P = $P;
	}
}
print $most_prob_kmer;
print "\n";
print $largest_P;
print "\n";

exit;

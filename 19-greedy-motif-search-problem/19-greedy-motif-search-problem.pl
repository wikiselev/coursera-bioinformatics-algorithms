#!usr/bin/perl -w

# GREEDYMOTIFSEARCH(Dna, k,t)
# form a set of k-mers BestMotifs by selecting 1st k-mers in each string from Dna
# for each k-mer Motif in the 1st string from Dna
#     Motif1 ← Motif
#     for i = 2 to t
#         form Profile from motifs Motif1, …, Motifi - 1
#         Motifi ← Profile-most probable k-mer in the i-th string in Dna
#     Motifs ← (Motif1, …, Motift)
#     if Score(Motifs) < Score(BestMotifs)
#         BestMotifs ← Motifs
# output BestMotifs

# Input: Integers k and t, followed by a collection of strings Dna.

# Output: A collection of strings BestMotifs resulting from applying GREEDYMOTIFSEARCH(Dna,k,t). If at any step you find more than one Profile-most probable k-mer in a given string, use the one occurring first.

# Sample Input:
# 3 5
# GGCGTTCAGGCA
# AAGAATCAGTCA
# CAAGGAGTTCGC
# CACGTCAATCAC
# CAATAATATTCG

# Sample Output:
# CAG
# CAG
# CAA
# CAA
# CAA

use Storable qw(dclone);
use List::Util 'max';
use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

my $param = $data[0];
chomp $param;
my @param = split(' ', $param);

my $k = $param[0];
my $t = $param[1];

my @Dna = @data[1 .. scalar @data - 1];
chomp(@Dna);

my @Alphabet = ('A', 'C', 'T', 'G');
my %Profile;

sub formProfile {
	my @motifs = @{ dclone($_[0]) };
	my $i;
	my $j;
	undef %Profile;
	for ($i = 0; $i < $k; $i++) {
		foreach (@Alphabet) {
			push ( @{$Profile{$_}}, 0 );
		}
	}

	for ($i = 0; $i < $k; $i++) {
		foreach my $m (@motifs) {
			@{$Profile{substr($m, $i, 1)}}[$i]+=1/$t;
		}
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

sub ProfileMostProbKmer {
	my $kmer;
	my $most_prob_kmer = substr($_[0], 0, $k);
	my $P;
	my $largest_P = &Probability($most_prob_kmer);

	for (my $i = 0; $i <= (length($_[0]) - $k); $i++) {
		$kmer = substr($_[0], $i, $k);
		$P = &Probability($kmer);
		if ( $P > $largest_P ) {
			$most_prob_kmer = $kmer;
			$largest_P = $P;
		}
	}
	return $most_prob_kmer;
}

sub hd{ length( $_[ 0 ] ) - ( ( $_[ 0 ] ^ $_[ 1 ] ) =~ tr[\0][\0] ) }

sub Score{
	my @motifs = @{ dclone($_[0]) };
	my $let;
	my $prob;
	my $prob_max;
	my @prob;
	my @consensus;
	my $score = 0;
	for (my $i = 0; $i < $k; $i++) {
		$prob_max = 0;
		foreach (keys %Profile){
			$prob = ${$Profile{$_}}[$i];
			if ( $prob > $prob_max ) {
				$prob_max = $prob;
				$let = $_;
			}
		}
		push ( @consensus, $let );
	}

	my $consensus = join('', @consensus);

	foreach my $m (@motifs) {
		$score = $score + &hd( $m, $consensus);
	}
	return $score;
}

my @BestMotifs;
for (my $i = 0; $i < $t; $i++) {
	push ( @BestMotifs, substr( $Dna[$i], 0, $k ) );
}
&formProfile(\@BestMotifs);
my $BestScore = &Score(\@BestMotifs);
my $score;
my @Motifs;

for (my $j = 0; $j <= (length($Dna[0]) - $k); $j++) {
	@Motifs = ();
	push ( @Motifs, substr($Dna[0], $j, $k) );
	for (my $i = 1; $i < $t; $i++) {
		&formProfile(\@Motifs);
		push ( @Motifs, &ProfileMostProbKmer($Dna[$i]) );
	}
	&formProfile(\@Motifs);
	$score = &Score(\@Motifs);
	if ( $score < $BestScore ) {
		@BestMotifs = @Motifs;
		$BestScore = $score;
	}
}

print join("\n", @BestMotifs);
print "\n";

exit;

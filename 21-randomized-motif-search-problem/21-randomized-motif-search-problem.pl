#!usr/bin/perl -w

# RANDOMIZEDMOTIFSEARCH(Dna, k, t)
# randomly select k-mers Motifs = (Motif1, …, Motift) in each string from Dna
# BestMotifs ← Motifs
# while forever
#     Profile ← Profile(Motifs)
#     Motifs ← Motifs(Profile, Dna)
#     if Score(Motifs) < Score(BestMotifs)
#         BestMotifs ← Motifs
#     else
#         output BestMotifs
#         return

# Input: Integers k and t, followed by a collection of strings Dna.
# Output: A collection BestMotifs resulting from running RANDOMIZEDMOTIFSEARCH(Dna, k, t) 1000 times.
# Remember to use pseudocounts!

# Sample Input:
# 8 5
# CGCCCCTCTCGGGGGTGTTCAGTAAACGGCCA
# GGGCGAGGTATGTGTAAGTGCCAAGGTGCCAG
# TAGTACCGAGACCGAAAGAAGTATACAGGCGT
# TAGATCAAGTTTCAGGTGCACGTCGGTGAACC
# AATCCACCAGCTCCACGTGCAATGTTGGCCTA

# Sample Output:
# TCTCGGGG
# CCAAGGTG
# TACAGGCG
# TTCAGGTG
# TCCACGTG

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
			push ( @{$Profile{$_}}, 1 );
		}
	}

	for ($i = 0; $i < $k; $i++) {
		foreach my $m (@motifs) {
			@{$Profile{substr($m, $i, 1)}}[$i]+=1;
		}
	}

	for ($i = 0; $i < $k; $i++) {
		foreach (@Alphabet) {
			@{$Profile{$_}}[$i]/=(4 + scalar(@motifs));;
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

sub RandMotifs {
	my @motifs;
	for (my $i = 0; $i < $t; $i++) {
		push ( @motifs, substr( $Dna[$i], rand()*(length($Dna[0]) - $k), $k ) );
	}
	return @motifs;
}

my @Motifs;
my @BestMotifs;
my $BestScore;
my $score;
@Motifs = &RandMotifs;
@BestMotifs = @Motifs;
&formProfile(\@BestMotifs);
$BestScore = &Score(\@BestMotifs);
for (my $j = 0; $j < 1000; $j++) {
	while (1) {
		&formProfile(\@Motifs);
		undef @Motifs;
		for (my $i = 0; $i < $t; $i++) {
			push ( @Motifs, &ProfileMostProbKmer($Dna[$i]) )
		}
		$score = &Score(\@Motifs);
		if ( $score < $BestScore ) {
			@BestMotifs = @Motifs;
			$BestScore = $score;
		} else {
			print join("\n", @BestMotifs);
			print "\n";
			print $BestScore;
			print "\n";
			@Motifs = &RandMotifs;
			last;
		}
	}
}

exit;

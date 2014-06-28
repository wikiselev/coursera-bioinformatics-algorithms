#!usr/bin/perl -w

# GIBBSSAMPLER(Dna, k, t, N)
# randomly select k-mers Motifs = (Motif1, …, Motift) in each string from Dna
# BestMotifs ← Motifs
# for i from 1 to N
#    i ← Random(t)
#    construct profile matrix Profile from all strings in Motifs except for Motifi
#    Motifi ← Profile-randomly generated k-mer in the i-th sequence
#    if Score(Motifs) < Score(BestMotifs)
#        BestMotifs ← Motifs
# output BestMotifs

# Input: Integers k, t, and N, followed by a collection of strings Dna.
# Output: The strings BestMotifs resulting from running GIBBSSAMPLER(Dna, k, t, N) with
# 20 random starts. Remember to use pseudocounts!

# Sample Input:
# 8 5 100
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
use POSIX;
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
my $N = $param[2];

my @Dna = @data[1 .. scalar @data - 1];
chomp(@Dna);

my @Alphabet = ('A', 'C', 'T', 'G');
my %Profile;


my @Probability;# = (0.1, 0.1, 0.1, 0.1, 0.1);
# print &ProfileRandomlyGeneratedKmer("ADFSDFSFSDFV");
# print "\n";

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

sub ProfileRandomlyGeneratedKmer {
	my @cumProbability;
	for (my $i = 0; $i < scalar @Probability; $i++) {
		push ( @cumProbability, eval join '+', @Probability[0 .. $i] );
	}

	my $rn = rand()*max(@cumProbability);

	my $res;
	for (my $i = 0; $i < scalar @cumProbability; $i++) {
		if ( $cumProbability[$i] > $rn ) {
			$res = $i;
			last;
		}
	}

	# print join(' ', @Probability);
	# print "\n";
	# print join(' ', @cumProbability);
	# print "\n";
	# print $rn . "\n";
	# print $res . "\n";
	# print $_[0];
	# print "\n";
	return ( substr( $_[0], $res, $k ) );
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

my $m;
my @Motifs;
my @BestMotifs;
my $BestScore;
my $score;
@Motifs = &RandMotifs;
@BestMotifs = @Motifs;
&formProfile(\@BestMotifs);
$BestScore = &Score(\@BestMotifs);
for (my $j = 0; $j < 20; $j++) {
	print $j . "\n";
	@Motifs = &RandMotifs;
	for (my $l = 0; $l < $N; $l++ ) {
		$m = floor($t*rand());
		splice ( @Motifs, $m, 1 );
		&formProfile(\@Motifs);
		undef @Probability;
		for (my $i = 0; $i < length($Dna[$m]) - $k; $i++) {
			push ( @Probability, &Probability(substr($Dna[$m], $i, $k)) );
		}
		splice ( @Motifs, $m, 0, &ProfileRandomlyGeneratedKmer($Dna[$m]) );
		$score = &Score(\@Motifs);
		if ( $score < $BestScore ) {
			@BestMotifs = @Motifs;
			$BestScore = $score;
		}
	}
}

print join("\n", @BestMotifs);
print "\n";
print join("\n", $BestScore);
print "\n";

exit;

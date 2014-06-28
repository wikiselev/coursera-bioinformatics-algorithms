#!usr/bin/perl -w

# Input: An integer M, an integer N, and a collection of (possibly repeated) integers Spectrum.

# Output: A cyclic peptide LeaderPeptide with amino acids taken only from the top M elements (and ties) of the convolution of Spectrum that fall between 57 and 200, and where the size of Leaderboard is restricted to the top N (and ties).

# Sample Input:
#      20
#      60
#      57 57 71 99 129 137 170 186 194 208 228 265 285 299 307 323 356 364 394 422 493

# Sample Output:
#      99-71-137-57-72-57

use List::Util 'max';
use List::Util 'min';
use Storable qw(dclone);
use List::MoreUtils qw/ uniq /;
use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

# save M (the top M elements (and ties) of the convolution of Spectrum that 
# fall between 57 and 200)
my $M = $data[0];
chomp($M);

# save N (N highest-scoring peptides)
my $N = $data[1];
chomp($N);

# save the theoretical peptide spectrum
my $Spectrum = $data[2];
chomp($Spectrum);
my @Spectrum = split(' ', $Spectrum);
@Spectrum = sort { $a <=> $b } @Spectrum;
# if ( $Spectrum[0] != 0 ) {
# 	unshift ( @Spectrum, 0 );
# }

# import codon table into a hash
my @molMass = &Convolution(\@Spectrum);

sub Convolution {
	my @s = @{ dclone($_[0]) };
	my @convolution;
	my $dif = 0;
	for ( my $i = 1; $i < scalar @s; $i++ ) {
		for ( my $j = 0; $j < $i; $j++ ) {
			$dif = $s[$i] - $s[$j];
			if ( $dif > 0 ) {
				push ( @convolution, $s[$i] - $s[$j] );
			}
		}
	}
	@convolution = grep { ( $_ >= 57 ) && ( $_ <= 200 ) } @convolution;
	my %seen;
	@seen{uniq @convolution} = 0;
	foreach ( @convolution ) {
		$seen{$_}++;
	}
	my @keys = sort { $seen{$b} <=> $seen{$a} } keys(%seen);
	if ( scalar @keys <= $M) {
		return @keys;
	} else {
		return @keys[0..($M - 1)]
	}
}

sub Expand {
	my @l = @{ dclone($_[0]) };
	my @l1;
	if ( scalar @l != 1 ) {
		foreach my $str (@l) {
			foreach (@molMass) {
				push ( @l1, join('-', $str, $_) );
			}
		}
	} else {
		foreach my $str (@l) {
			foreach (@molMass) {
				push ( @l1, $_ );
			}
		}
	}
	return @l1;
}

sub Cyclospectrum_old {
	# local($pep);	
	my @pep = split('-', $_[0]);

	# make the peptide cyclic
	my @pepCyclic = (@pep, @pep);

	my @peps = ();
	my $i;
	my $j;
	my $tmp;

	# record all sub cyclopeptides to @peps
	for ( $i = 0; $i < scalar @pep - 1; $i++ ) {
		$j = 0;
		foreach ( @pep ) {
			if ( $i != 0 ){
				$tmp = $_ . '-' . join('-', @pepCyclic[($j+1)..($j + $i)]);
			} else {
				$tmp = $_;
			}
			push ( @peps, $tmp );
			$j++;
		}
	}

	@peps = (@peps, join('-', @pep));

	# calculate and print masses of all sub cyclopeptides
	my $mass = '0';
	my @mass = ('0');
	foreach (@peps) {
		foreach (split('-', $_)) {
			$mass = $mass + $_;
		}
		push ( @mass, $mass );
		$mass = '0';
	}
	return ( @mass );
}

sub Cyclospectrum {
	# local($pep);	
	my @pep = split('-', $_[0]);

	# make the peptide cyclic
	my @pepCyclic = (@pep, @pep);

	my $i;
	my $j;
	my $tmp;
	my $mass = '0';
	my @mass = ('0');

	# record all sub cyclopeptides to @peps
	for ( $i = 0; $i < scalar @pep - 1; $i++ ) {
		$j = 0;
		foreach ( @pep ) {
			if ( $i != 0 ){
				$mass = $mass + $_ + eval join '+', @pepCyclic[($j+1)..($j + $i)];
			} else {
				$mass = $mass + $_;
			}
			push ( @mass, $mass );
			$mass = '0';
			$j++;
		}
	}

	push ( @mass,  eval join '+', @pep );

	return ( @mass );
}

sub Mass {
	return ( eval join '+', split('-', $_[0]) );
}

sub Score {
	my @theorSpec = &Cyclospectrum($_[0]);
	my @expSpec = @Spectrum;
	@theorSpec = sort { $a <=> $b } @theorSpec;
	my $SpecMax = max @expSpec;
	my $i = 0;
	my $score = 0;
	my @a;
	my @b;
	# print scalar @theorSpec;
	# print "\n";
	while ( scalar @theorSpec > 0 ) {
		# print join(' ', $theorSpec[0], $expSpec[0]);
		# print "\n";
		if ( $theorSpec[0] == $SpecMax ) {
			@a = grep { $_ == $SpecMax } @theorSpec;
			@b = grep { $_ == $SpecMax } @expSpec;
			$score = $score + min ( scalar @a, scalar @b );
			last;
		}
		if ( $theorSpec[0] > $SpecMax ) {
			last;
		}
		if ( $theorSpec[0] == $expSpec[0] ) {
			$score++;
			splice(@theorSpec, 0, 1);
			splice(@expSpec, 0, 1);
		}
		if ( $theorSpec[0] < $expSpec[0] ) {
			splice(@theorSpec, 0, 1);
		}
		if ( $theorSpec[0] > $expSpec[0] ) {
			for ( $i = 1; $i < scalar @expSpec; $i++ )
			{
				if ( $theorSpec[0] < $expSpec[$i] ) {
					splice(@theorSpec, 0, 1);
					splice(@expSpec, 0, $i - 1);
					last;
				}
				if ( $theorSpec[0] == $expSpec[$i] )
				{
					$score++;
					splice(@theorSpec, 0, 1);
					splice(@expSpec, $i, 1);
					last;
				}
			}
		}
	}


	# print join(' ', @theorSpec);
	# print "\n";
	# print join(' ', @expSpec);
	# print "\n";
	return $score;
}


sub Score_old {
	my @theorSpec = &Cyclospectrum($_[0]);
	my @expSpec = @Spectrum;
	my $i = 0;
	# print join(' ', @expSpec);
	# print "\n";
	for my $th ( @theorSpec ) {
		for my $exp ( @expSpec ) {
			if ( $th eq $exp) {
				$i++;
				$exp = "seen";
				last;
			}
		}
	}
	# print join(' ', @theorSpec);
	# print "\n";
	# print join(' ', @expSpec);
	# print "\n";
	return $i;
}

sub Score_old {
	my @theorSpec = &Cyclospectrum($_[0]);
	my @expSpec = @Spectrum;
	my $i = 0;

	for my $sp (@theorSpec) {
		$sp++ if ! grep {$sp == $_} @expSpec;
	}

	return scalar @theorSpec;
}

# @a2 = eigenstates(any(@a2) != all(@a1));

sub Cut {
	my @pep = @{ dclone($_[0]) };
	my @scores = @{ dclone($_[1]) };
	my $n = $_[2];
	my @sortedScores = ();
	my $i = $n;
	my $threshold;
	my @result = ();

	# print scalar @pep;
	# print "\n";
	# print scalar @scores;
	# print "\n";
	# print $n . "\n";

	if ( scalar @pep <= $n ) {
		return @pep;
	} else {
		@sortedScores = sort { $b <=> $a } @scores;
		while ( $sortedScores[$i] == $sortedScores[$i - 1] ) {
			$i++;
			if ( $i == scalar @sortedScores ) {
				$i--;
				last;
			}
		}
		$threshold = $sortedScores[$i - 1];
		for ( $i = 0; $i < scalar @pep; $i++ ) {
			if ( $scores[$i] >= $threshold ) {
				push ( @result, $pep[$i] );
			}
		}
	}
	return @result;
	# print join( ' ', @sortedScores );
	# print "\n";
	# print join( ' ', @scores );
	# print "\n";

}

my @Leaderboard = ('');
my @LeaderboardScores = ();
my $Score;
my $LeaderPeptide = '';
my $ParentMass = max split( ' ', $Spectrum );
my $ScoreLeaderPeptide = 0;

# print &Mass("1-2-3") . "\n";
# print $ParentMass . "\n";
# print $N . "\n";
# print &Score( "113-147-71");
# my @test1 = ('a', 'b', 'c', 'd', 'e', 'f');
# my @test2 = (1, 3, 1, 1, 1, 4);
# print join(' ', &Cut( \@test1, \@test2, 3 ));

# for ( my $i = 0; $i < 4; $i ++ ) {
while ( scalar @Leaderboard != 0 ) {
	print scalar @Leaderboard;
	print "\n";
	@Leaderboard = &Expand( \@Leaderboard );
	# print join( ' ', @Leaderboard );
	# print "\n";
	# print "\n";
	@LeaderboardScores = ();
	foreach ( @Leaderboard ) {
		# print &Mass( $_ ) . "\n";
		if ( &Mass( $_ ) == $ParentMass ) {
			# if ( $_ eq "113-147-71-129" )
			# {
			# 	print $ScoreLeaderPeptide . "\n";
			# 	print &Score( "113-147-71-129" ) . "\n";
			# 	print $LeaderPeptide . "\n";
			# }
			$Score = &Score( $_ );
			push ( @LeaderboardScores, $Score );
			# print $Score . "\n";
			if ( $Score > $ScoreLeaderPeptide ) {
				$LeaderPeptide = $_;
				$ScoreLeaderPeptide = $Score;
			}
			# if ( $_ eq "113-147-71-129" )
			# {
			# 	print $ScoreLeaderPeptide . "\n";
			# 	print &Score( "113-147-71-129" ) . "\n";
			# 	print $LeaderPeptide . "\n";

			# }

		} else {
			if ( &Mass($_) > $ParentMass ) {
				$_ = "remove";
			} else {
				$Score = &Score( $_ );
				push ( @LeaderboardScores, $Score );
			}
		}
	}
	@Leaderboard = grep { $_ ne "remove" } @Leaderboard;
	# print join( ' ', @Leaderboard );
	# print "\n";
	# print "\n";
	@Leaderboard = &Cut( \@Leaderboard, \@LeaderboardScores, $N );
	# print join( ' ', @Leaderboard );
	# print "\n";
}
	# print join( ' ', @Leaderboard );
	# print "\n";
	# print "\n";
	# print $ScoreLeaderPeptide . "\n";
	# print join(' ', &Cyclospectrum( "71-147-113" ));
	# print &Mass( "113-147-71-129" ) . "\n";
	# print $ParentMass . "\n";


print $LeaderPeptide . "\n";
exit;

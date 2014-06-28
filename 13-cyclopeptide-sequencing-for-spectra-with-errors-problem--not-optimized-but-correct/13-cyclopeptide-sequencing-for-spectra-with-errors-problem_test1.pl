#!usr/bin/perl -w

# CYCLOPEPTIDE SEQUENCING
# CYCLOPEPTIDESEQUENCING(Spectrum)
    # List ← {0-peptide}
    # while List is nonempty
    #     List ← Expand(List)
    #     for each peptide Peptide in List
    #         if Cyclospectrum(Peptide) = Spectrum
    #             output Peptide
    #             remove Peptide from List
    #         else if Peptide is not consistent with Spectrum
    #             remove Peptide from List

# Sample Input:
#      0 113 128 186 241 299 314 427

# Sample Output:
#      186-128-113 186-113-128 128-186-113 128-113-186 113-186-128 113-128-186
# use Quantum::Superpositions;
use List::Util 'max';
use List::Util 'min';
use Array::Utils qw(:all);
use Storable qw(dclone);
use strict;
use warnings;

# import codon table into a hash
open(F, 'amino-acid-mol-mass.txt');
my @molMass = <F>;
close F;
chomp(@molMass);

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

# save N (N highest-scoring peptides)
my $N = $data[0];
chomp($N);

# save the theoretical peptide spectrum
my $Spectrum = $data[1];
chomp($Spectrum);
my @Spectrum = split(' ', $Spectrum);
@Spectrum = sort { $a <=> $b } @Spectrum;

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

sub Score_old_old {
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
	my %hash;
	@hash{@pep} = @scores;
	my $n = $_[2];
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
		my @keys = sort { $hash{$b} <=> $hash{$a} } keys(%hash);
		my @vals = @hash{@keys};
		$threshold = $vals[$n];
		@result = grep { $hash{$_} >= $threshold } keys %hash;
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
my $mass;


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
		$mass = &Mass( $_ );
		if ( $mass == $ParentMass ) {
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
			if ( $mass > $ParentMass ) {
				$_ = "remove";
			} 
			else {
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

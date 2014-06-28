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

use List::Util 'max';
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

# save the theoretical peptide spectrum
my $Spectrum = $data[0];
chomp($Spectrum);
my @Spectrum = split(' ', $Spectrum);

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

sub Cyclospectrum {
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

sub Linearspectrum {
	# local($pep);	
	my @pep = split('-', $_[0]);

	my @peps = ();
	my $tmp;

	# record all sub cyclopeptides to @peps
	for ( my $i = 0; $i < scalar @pep - 1; $i++ ) {
		for ( my $j = 0; $j < scalar @pep - $i; $j++) {
			if ( $i != 0 ){
				$tmp = $pep[$j] . '-' . join('-', @pep[($j+1)..($j + $i)]);
			} else {
				$tmp = $pep[$j];
			}
			push ( @peps, $tmp );
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

sub SpectrumEquality {
	my @s1 = @{ dclone($_[0]) };
	my @s2 = @{ dclone($_[1]) };
	@s1 = sort { $a <=> $b } @s1;
	@s2 = sort { $a <=> $b } @s2;
	if ( @s1 ~~ @s2 ) {
		return 1;
	} else {
		return 0;
	}
}

sub SpectrumConsistency {
	my @s1 = @{ dclone($_[0]) };
	my @s2 = @{ dclone($_[1]) };

	my $b = 0;
	my $i = 0;
	my $j = 0;

	foreach my $s1 ( @s1 ) {
		foreach ( @s1 ) {
			if( $s1 == $_ ) {
				$j++;
			}
		}
		foreach my $s2 ( @s2 ) {
			if ( $s1 == $s2 ) {
				$b = 1;
				$i++;
			}
		}
		if ( !($b == 1 && $i >= $j) ) {
			return 0;
		}
		$i = 0;
		$j = 0;
		$b = 0;
	}
	return 1;
}

my @List = ('');
my @cycloSpec;
my @linearSpec;

while ( scalar @List != 0 ) {
	print scalar @List;
	print "\n";
	@List = &Expand( \@List );
	foreach ( @List ) {
		@cycloSpec = &Cyclospectrum($_);
		@linearSpec = &Linearspectrum($_);
		if ( &SpectrumEquality(\@cycloSpec, \@Spectrum) ) {
			print $_ . " ";
			$_ = "remove";
		} else {
			if ( !&SpectrumConsistency(\@linearSpec, \@Spectrum) ) {
				$_ = "remove";				
			}
		}
	}
	@List = grep { $_ ne "remove" } @List;
}

print "\n";
exit;

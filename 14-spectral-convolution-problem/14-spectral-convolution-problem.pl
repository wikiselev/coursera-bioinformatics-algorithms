#!usr/bin/perl -w

# Spectral Convolution Problem: Compute the convolution of a spectrum.
#      Input: A collection of integers Spectrum.
#      Output: The list of elements in the convolution of Spectrum. If an element has multiplicity k, it should
#      appearexactly k times; you may return the elements in any order.

# Sample Input:
#      0 137 186 323

# Sample Output:
#      137 137 186 186 323 49

use List::Util 'max';
use Storable qw(dclone);
use List::MoreUtils qw/ uniq /;
use strict;
use warnings;

# read the input file
open(F, 'input.txt');
my @data = <F>;
close F;

# save the theoretical peptide spectrum
my $Spectrum = $data[0];
chomp($Spectrum);
my @Spectrum = split(' ', $Spectrum);
@Spectrum = sort { $a <=> $b } @Spectrum;

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
	return @convolution;
}

print join(' ', &Convolution(\@Spectrum));
print "\n";
exit;

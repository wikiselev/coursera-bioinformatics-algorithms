#!usr/bin/perl -w

# Clump Finding Problem: Find patterns forming clumps in a string.
#      Input: A string Genome, and integers k, L, and t.
#      Output: All distinct k-mers forming (L, t)-clumps in Genome.

# Sample Input:
#      CGGACTCGACAGATGTGAAGAACGACAATGTGAAGACTCGACACGACAGAGTGAAGAGAAGAGGAAACATTGTAA
#      5 50 4

# Sample Output:
#      CGACA GAAGA

use List::Util qw( min max );

# subroutine implemented from 1-frequent-words-problem
sub FrequentWords{
   my @list = @_;
   my $k = $list[0];
   my $string = $list[1];
   my $freq = $list[2];
   my @motifs;

   # save all the k-mers that appear in the input string into the @motifs array
   for ($i = 0; $i <= (length($string) - $k - 1); $i++) {
   		push (@motifs, substr($string, $i, $k));
   }

   # make hash for @motifs and calculate the frequency of each motif appearance
   my %seen;
   foreach ( @motifs ) { 
       $seen{$_}++;
   }

   # access the hash by the value of $freq and save all motifs that appear with
   # frequency larger than $freq
   my @keys = grep { $seen{$_} >= $freq } keys %seen;
   return @keys;
}

# read the input
open(F, 'E-coli.txt');
my @data = <F>;
close F;

# assign variables to the input data
my $genome = $data[0];
my $param = $data[1];

# remove end of line characters
chomp($genome);
chomp($param);

# extract all parameters from the input data
my @par = split(/ /, $param);
my $k = $par[0];
my $L = $par[1];
my $t = $par[2];

# define sliding window variable and output patterns array
my $string;
my @patterns;

# slide $string along the $genome
for ($j = 0; $j <= (length($genome) - $L); $j++) {
   # define the $string sequence
   $string = substr($genome, $j, $j + $L);
   # get patterns with clumps and record them to @patterns
   push (@patterns, &FrequentWords($k, $string, $t));
}

# find only unique patterns in @patterns
my %seen;
my @unique = grep { ! $seen{$_}++ } @patterns;

# print the results
print join( ' ', @unique );
print "\n";

exit;

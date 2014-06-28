#!usr/bin/perl -w

# Reverse Complement Problem: Reverse complement a nucleotide pattern.
#      Input: A DNA string Pattern.
#      Output: Pattern, the reverse complement of Pattern.

# Sample Input:
#      AAAACCCGGT

# Sample Output:
#      ACCGGGTTTT

# read the input
open(F, 'input.txt');
my @data = <F>;
close F;

# assign variables to the input data
my $string = $data[0];

# complement the string
$string =~ tr/ACGT/TGCA/;
# reverse the string
$string = reverse $string;

# print the reversed complement
print $string;
print "\n";

exit;

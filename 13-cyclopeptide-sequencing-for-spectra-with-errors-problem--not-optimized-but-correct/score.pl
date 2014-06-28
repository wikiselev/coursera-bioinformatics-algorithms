use List::Util 'max';
use List::Util 'min';
use Array::Utils qw(:all);

my @Spectrum = (1, 2, 3, 5, 6, 6, 6, 6, 8);
# my %Spectrum = map +($_ => 1), @Spectrum;
# print join(' ', %Spectrum);
# print "\n";
my @pepSpec = (0, 2, 3, 4, 5, 5, 6, 6, 7);

sub Score {
	my @theorSpec = @pepSpec;
	my @expSpec = @Spectrum;
	@result = array_diff( @expSpec, @theorSpec );#grep !$Spectrum{$_[0]}, @theorSpec;
	return @result;
}

print &Score;
print "\n";

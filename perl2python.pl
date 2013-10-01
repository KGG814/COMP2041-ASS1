#!/usr/bin/perl
use warnings;
use strict;
our @lines = ();
while (my $line = <>) {
	chomp $line;
	$line = &pythonInitialise($line);
	$line = &removeSemicolons($line);
	$line = &removeNewlinePrint($line);
	$line = &printSimple($line);
	#$line = &interpolate($line);
	$line = &convertVars($line);
	
	push @lines, $line;	
}

print "$_\n" for @lines;
# Set first line to use python compiler
sub pythonInitialise {
	if ($_[0] =~ m/^#!/ and $. == 1) {		
		return "#!/usr/bin/python2.7 -u";		
	}
	return $_[0];
}

# Strip semicolons
sub removeSemicolons {
	if ($_[0] =~ m/^(.*);/) {
			return $1;
	}
	return $_[0];
}

# Python's print adds a new-line character by default
# so we need to delete it from the Perl print statement
sub removeNewlinePrint {
	if ($_[0] =~ m/^print\s*\"([^\"]*)\\n\"[\s]*$/) {	
			return "print '$1'";
	}
	return $_[0];
}

# print a single variable without interpolating
sub printSimple {
	if ($_[0] =~ /^print \'(\$[^\"\s\$]+[\s\"]*)+\'/) {
		$_[0] =~ /^print \"(.*)\"/;
		my @varList = grep{/\S/} split(/\$/, $1);
		my $vars = join(",", @varList);
		$_[0] = "print $vars";
	}
	return $_[0];
}

# Variable interpolation, experimental
sub interpolate {
	while ($_[0] =~ /(.*\')([^\$]*)(\$[^\s\\]+)(.*\')/) {	
		my $sub = $3;
		$_[0] = "$1\%s$2$4 \% $3" ;
	}
   return $_[0];
}

#convert variables
sub convertVars {
	$_[0] =~ s/\$//;
	return $_[0];
}

sub testPrint {
	print "----------------\n\n";
	print "$_[0]\n";
	print "----------------\n\n";
}

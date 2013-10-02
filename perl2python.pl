#!/usr/bin/perl
use warnings;
use strict;
our @lines = ();
our $keepLine = 1;
while (my $line = <>) {
	$keepLine = 1;
	chomp $line;
	$line = &pythonInitialise($line);
	$line = &ifHandler($line);
	$line = &whileHandler($line);
	$line = &removeCurly($line);
	$line = &removeSemicolons($line);
	$line = &removeNewlinePrint($line);
	$line = &printSimple($line);
	#$line = &interpolate($line);
	$line = &convertVars($line);
	
	push @lines, $line if $keepLine;	
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
	if ($_[0] =~ m/(\s*print)\s*\"([^\"]*)\\n\"[\s]*$/) {	
		return "$1 '$2'";
	} elsif ($_[0] =~ /(\s*print.*), "\\n"\s*$/) {
		testPrint($1);
		return $1;
	}
	return $_[0];
}

# print variables without interpolating
sub printSimple {
	# Match for print containing only variables
	if ($_[0] =~ /^print \'(\$[^\'\s\$]+[\s\']*)+\'/) {
		# Match the variables
		$_[0] =~ /^(\s*print) \'(.*)\'/;
		# Split on $, grep for non-empty lines
		my @varList = grep{/\S/} split(/\$/, $2);
		my $vars = join(",", @varList);
		$_[0] = "$1 $vars";
	}
	return $_[0];
}

# Variable interpolation, experimental
sub interpolate {
	# Looks for things that look like variables, one at a time
	while ($_[0] =~ /(.*\')([^\$]*)(\$[^\s\\]+)(.*\')/) {	
		my $sub = $3;
		$_[0] = "$1\%s$2$4 \% $3" ;
	}
   return $_[0];
}

# Removes curly braces and brackets from if statements, adds a colon
sub ifHandler {
	if ($_[0] =~ /^\s*if.*{\s*$/) {
		# Replace curly brace with colon
		$_[0] =~ s/\s*{\s*$/:/;
		# Remove brackets
		$_[0] =~ s/[()]//g;
	}
	
	return $_[0]
}

#Removes curly braces and brackets from while statements, adds a colon
#TODO Make sure nesting works
sub whileHandler {
	# Match for while
	if ($_[0] =~ /^\s*while.*{\s*$/) {
		# Replace curly brace with colon
		$_[0] =~ s/\s*{\s*$/:/;
		# Remove brackets
		$_[0] =~ s/[()]//g;
	}
	
	return $_[0]
}

#Removes lines with curly braces by themselves
sub removeCurly {
	# If line is single curly brace, remove line
	if ($_[0] =~ /^\s*}\s*$/) {
		$keepLine = 0;
	}
	return $_[0]
}

# Convert variables to python by removing $
#TODO only remove if there are an even number of single quotes on either side and not escaped
sub convertVars {
	$_[0] =~ s/\$//g;
	return $_[0];
}


#TODO Add break and continue
#TODO Check bitwise works the same in python
#TODO For statements
#TODO Handle ++ and --
sub testPrint {
	print "----------------\n\n";
	print "$_[0]\n";
	print "----------------\n\n";
}

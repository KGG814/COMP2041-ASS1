#!/usr/bin/perl
use strict;
our @lines = ();
our $keepLine = 1;
while (my $line = <>) {
	$keepLine = 1;
	chomp $line;
	$line = &pythonInitialise($line);
	$line = &removeSemicolons($line);
	$line = &ifHandler($line);
	$line = &whileHandler($line);
	$line = &perlFor($line);
	$line = &cFor($line);	
	$line = &removeCurly($line);
	$line = &nextLast($line);
	$line = &equality($line);
	$line = &joinHandler($line);
	$line = &removeNewlinePrint($line);
	$line = &printSimple($line);
	$line = &interpolate($line);
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
	if ($_[0] =~ m/^(.*);$/) {
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
#TODO only remove if there are an even number of single/double quotes on either side and not escaped
sub convertVars {
	$_[0] =~ s/\$//g;
	return $_[0];
}

# Converts next and last to continue and break
sub nextLast {
	if ($_[0] =~ /^\s*next$/) {
		$_[0] =~ s/next/continue/;
	} elsif ($_[0] =~ /^\s*last$/) {
		$_[0] =~ s/last/break/;
	}
	return $_[0];
}

# Converts perl string equality operator to python equality operator
# TODO type-checking eg. numerical equality
sub equality {
	if ($_[0] =~ / eq /) {
		$_[0] =~ s/ eq / == /;
	}
	return $_[0];
}

# Handles perl style for loops
sub perlFor {
	if ($_[0] =~ /for \S* \(\S*\)/) {
		$_[0] =~ s/for (\S*) \((\S*)\) /for \1 in \2/;
	}
	return $_[0];
}

# Handles C style for loops
sub cFor {
	if ($_[0] =~ /(\s*)for \(\$(\S+) = (\d+); \$\S+ < (\d+); \$\S+ [\+-]= (\d+)\)/) {
		$_[0] = "$1for $2 in range($3, $4, $5):";
	}
	return $_[0];
}

# Handles increment/decrement
sub incDec {
	$_[0] =~ s/++/+=1/;
	$_[0] =~ s/--/-=1/;
	return $_[0];
}

# Handles join
sub joinHandler {
	if ($_[0] =~ /join\(.+, .+\)/ {
		$_[0] =~ s/join\((.+), (.+)\)/\1\.join\(\2\)/;
	}
}

#TODO Check if _ is a valid variable name in python
sub splitHandler {
	if ($_[0] =~ /split\(.+, .+, .+\)/ {
		$_[0] =~ s/split\((.+), (.+), (.+)\)/re\.split\(\1, \2, \3\)/;
	} elsif ($_[0] =~ /split\(.+, .+\)/ {
		$_[0] =~ s/split\((.+), (.+)\)/re\.split\(\1, \2\)/;
	} elsif ($_[0] =~ /split\(.+\)/ {
		$_[0] =~ s/split\((.+), (.+)\)/re\.split\(\1, \_\)/;
	}
}
#TODO Perl style backwards if statements
#TODO Chomp
#TODO arguments

sub testPrint {
	print "----------------\n\n";
	print "$_[0]\n";
	print "----------------\n\n";
}

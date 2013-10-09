#!/usr/bin/perl
use strict;
our @lines = ();
our %imports = ();
our $keepLine = 1;
while (my $line = <>) {
	$keepLine = 1;
	chomp $line;
	$line = &pythonInitialise($line);
	$line = &removeSemicolons($line);
	$line = &substitutionHandler($line);
	$line = &unixFilterHandler($line);
	$line = &chompHandler($line);
	$line = &ifHandler($line);
	$line = &keysIterate($line);
	$line = &stdinLoopHandler($line);
	$line = &whileHandler($line);
	$line = &perlFor($line);
	$line = &listLengthArray($line);
	$line = &cFor($line);	
	$line = &removeCurly($line);
	$line = &nextLast($line);
	$line = &incDec($line);
	$line = &equality($line);
	$line = &joinHandler($line);
	$line = &splitHandler($line);
	$line = &pushHandler($line);
	$line = &spliceHandler($line);
	$line = &stdinHandler($line);
	$line = &scalarArrayHandler($line);
	$line = &removeNewlinePrint($line);
	$line = &printSimple($line);
	$line = &argvArrayHandler($line);
	$line = &interpolate($line);
	$line = &convertVars($line);
	
	push @lines, $line if $keepLine;	
}

print "#!/usr/bin/python2.7 -u\n";
print "import " if keys %imports;
print join(",",keys %imports), "\n";
print "$_\n" for @lines;

# Set first line to use python compiler
sub pythonInitialise {
	if ($_[0] =~ m/^#!/ and $. == 1) {		
		$keepLine = 0;		
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
		return $1;
	}
	return $_[0];
}

# print variables without interpolating
sub printSimple {
	# Match for print containing only variables
	if ($_[0] =~ /print \'(\$\w+(\[.*\])?[\s\']*)+\'/) {
		# Match the variables
		$_[0] =~ /^(\s*print) \'(.*)\'/;
		# Split on $, grep for non-empty lines
		my @varList = grep{/\S/} split(/[^\[]\$/, $2);
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

# Handles perl style for/foreach loops
sub perlFor {
	if ($_[0] =~ /for \S* \(\S*\)\s*{/) {
		$_[0] =~ s/for (\S*) \((\S*)\)\s*{/for \1 in \2:/;
		$_[0] =~ s/(\d)\.\.(\d)/xrange\(\1, \2\+1\)/
	} elsif ($_[0] =~ /foreach \S* \(\S*\)\s*{/) {
		$_[0] =~ s/foreach (\S*) \((\S*)\)\s*{/for \1 in \2:/;
		$_[0] =~ s/(\d)\.\.(\d)/xrange\(\1, \2\+1\)/
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
	$_[0] =~ s/\+\+/\+=1/;
	$_[0] =~ s/--/-=1/;
	return $_[0];
}

# Handles join
sub joinHandler {
	if ($_[0] =~ /join\(.+, .+\)/) {
		$_[0] =~ s/join\((.+), (.+)\)/\1\.join\(\2\)/;
	}
	return $_[0];
}

#TODO Check if _ is a valid variable name in python
sub splitHandler {
	if ($_[0] =~ /split\(.+, .+, .+\)/) {
		$imports{"re"}++;
		$_[0] =~ s/split\((.+), (.+), (.+)\)/re\.split\(\1, \2, \3\)/;
	} elsif ($_[0] =~ /split\(.+, .+\)/) {
		$imports{"re"}++;
		$_[0] =~ s/split\((.+), (.+)\)/re\.split\(\1, \2\)/;
	} elsif ($_[0] =~ /split\(.+\)/) {
		$imports{"re"}++;
		$_[0] =~ s/split\((.+), (.+)\)/re\.split\(\1, \_\)/;
	}
	return $_[0];
}

# Converts chomp
sub chompHandler {
	if ($_[0] =~ /chomp \$\S*/) {
		$_[0] =~ s/chomp \$(\S*)/\1 = \1\.rstrip\(\'\\n\'\)/;
	}
	return $_[0];
}

# Converts push
sub pushHandler {
	if ($_[0] =~ /push @\S+, \S+/) {
		$_[0] =~ s/push @(\S+), (.+)/\1\.append(\2)/;
	}
	return $_[0];
}

# Converts splice
sub spliceHandler {
	if ($_[0] =~ /scalar \(splice \(@\S+, .+, 1\)\)/) {
		$_[0] =~ s/scalar \(splice \(@(\S+), (.+), 1\)\)/\1\.pop\(\2\)/;
	}
	return $_[0];
}

# Scalar array handler
# For finding length of arrays
sub scalarArrayHandler {
	if ($_[0] =~ /scalar @\S+/) {
		$_[0] =~ s/scalar @(\S+)/len\(\1\)/;
	}
	return $_[0];
}

# Handles program pattern for iterating through keys
sub keysIterate {
	if ($_[0] =~ /for \$name \(keys %\S+\)/) {
		$_[0] =~ s/for \$(\S*) \(keys %(\S+) {\)/for \1 in \2\.keys\(\):/;
	}
	return $_[0];
}

# Handle loop use of STDIN
sub stdinLoopHandler {
	if ($_[0] =~ /while \(\$\w+ = <STDIN>\) {/) {
		$imports{"sys"}++;
		$_[0] =~ s/while \(\$(\w+) = <STDIN>\) {/for \1 in sys\.stdin:/
	}
	return $_[0];
}

# Handle basic use of STDIN
sub stdinHandler {
	if ($_[0] =~ /<STDIN>/) {
		$imports{"sys"}++;
		$_[0] =~ s/<STDIN>/sys.stdin.readline()/
	}
	return $_[0];
}

# Handle use of ARGV as array
sub argvArrayHandler {
	if ($_[0] =~ /\@ARGV/) {
		$_[0] =~ s/\@ARGV/sys.argv[1:]/;
		$imports{"sys"}++;
	}
	return $_[0];
}

# Handle use of ARGV elements
sub argvArrayHandler {
	if ($_[0] =~ /\$ARGV\[\$\w+\]/) {
		$_[0] =~ s/\$ARGV\[\$(\w+)\]/sys.argv[\1+1]/;
		$imports{"sys"}++;
	}
	return $_[0];
}

# Handles unix filter behaviour (<>)
sub unixFilterHandler {
	if ($_[0] =~ /while \(\$\S+ = <>\)/) {
		$_[0] =~ s/while \(\$(\S+) = <>\) {/for \1 in fileinput\.input\(\):/;
		$imports{"fileinput"}++;
	}
	return $_[0];
}

# Handles regexp substitution
sub substitutionHandler {
	if ($_[0] =~ /\$\S+ =~ s\/\S*\/\S*\/g/) {
		$_[0] =~ s/\$(\S+) =~ s\/(\S*)\/(\S*)\/g/\1 = re\.sub\(r'\2', '\3', \1\)/;
	}
	return $_[0];
}

# Handles perl .. notation
sub listLengthArray {
	if ($_[0] =~ /0\.\.\$#ARGV/) {
		$_[0] =~ s/0\.\.\$#ARGV/xrange\(len\(sys\.argv\) - 1\)/;
	}
	return $_[0];
}


#TODO Perl style backwards if statements
#TODO Handle numbers (floats ints, etc)
#TODO Arrays, hashes
#TODO shift, unshift, reverse

sub testPrint {
	print "----------------\n\n";
	print "$_[0]\n";
	print "----------------\n\n";
}

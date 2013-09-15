#!/usr/bin/perl
use warnings;

while ($line = <>) {
	if ($line =~ m/^#!/ and $. == 1) {
	
		# translate #! line 
		
		print "#!/usr/bin/python2.7 -u\n";
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
	
		# Blank & comment lines can be passed unchanged
		print $line;
	} else {
		# Strip commas
		if ($line =~ m/^(.*);/) {
			$line = $1;
		}
		# Python's print adds a new-line character by default
		# so we need to delete it from the Perl print statement
		if ($line =~ m/^\s*print\s*"(.*)\\n"[\s]*$/) {	
			$line = "print '$1'";
			while ($line =~ /'.*\$[a-zA-Z0-9]+.*'[\s]*/) {	
				$line =~ s/(\$[a-zA-Z0-9]+)/\%s/ or die;	
				$line = "$line, $1";
			}
		}
		print "$line\n";
	}
}

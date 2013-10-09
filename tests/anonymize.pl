#!/usr/bin/perl

open enrollments, "enrollments";
for $line (<enrollments>) {
	chomp $line;
	($course_code, $std_num, $name, $program, $plan, $wam, $semester, 
	 $birthdate, $gender)  = split(/\|/, $line);
	unless (@{$info{$name}}) {
		push @{$info{$name}}, $program;
		push @{$info{$name}}, $plan;
		push @{$info{$name}}, $wam;
		push @{$info{$name}}, $semester;
		push @{$info{$name}}, $birthdate;
		push @{$info{$name}}, $gender;
	}
	push @{$info{$name}}, $course_code; 
	
	$names{$name}++;
	$student_number{$name} = $std_num;	
}

for $name (keys %names) {
	$name =~ /(.*), (.*)$/;
	push @first_names, $2;
	push @last_names, $1;
}

close enrollments;
$count = 0;
for $name (keys %info) {
	push @programs, shift(@{$info{$name}});
	push @plans, shift(@{$info{$name}});
	push @wams, shift(@{$info{$name}});
	push @sems, shift(@{$info{$name}});
	push @birthdates, shift(@{$info{$name}});
	push @genders, shift(@{$info{$name}});
	push @student_numbers, $student_number{$name};
	push @courses, [@{$info{$name}}];
	
	$count++;
}


for $course_list (@courses) {
	@line = ();
	$name = scalar (splice (@last_names, rand scalar @last_names, 1)) . ", ".
			  scalar (splice (@first_names, rand scalar @first_names, 1));
	push @line, scalar (splice (@student_numbers, rand scalar @student_numbers, 1));
	push @line, $name;
	push @line, scalar (splice (@programs, rand scalar @programs, 1));
	push @line, scalar (splice (@wams, rand scalar @wams, 1));
	push @line, scalar (splice (@sems, rand scalar @sems, 1));
	push @line, scalar (splice (@birthdates, rand scalar @birthdates, 1));
	push @line, scalar (splice (@genders, rand scalar @genders, 1));
	$line = join("|", @line);
	while (@{$course_list}) {
		print shift(@{$course_list}), "|", $line, "\n";			
	}
}

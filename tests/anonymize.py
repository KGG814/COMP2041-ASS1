#!/usr/bin/python2.7 -u
from collections import defaultdict
enrollments = open ("enrollments", "r")
info = defaultdict(list);
names = dict();
student_number = dict();
for line in <enrollments>{
	line = line.rstrip('\n')
	(course_code, std_num, name, program, plan, wam, semester, 
	 birthdate, gender)  = re.split(/\|/, line)
	if not name in info:
		info[name].append(program)
		info[name].append(plan)
		info[name].append(wam)
		info[name].append(semester)
		info[name].append(birthdate)
		info[name].append(gender)
	info[name].append(course_code)
	
	names[name]+=1
	student_number[name] = std_num;	

for name in names.keys():
	m = re.match("(.*), (.*)",  name)
	first_names.append(m.group(2))
	last_names.append(m.group(1))

close enrollments
count = 0
for name in info.keys(): {
	programs.append(info[name].pop(0))
	plans.append(info[name].pop(0))
	wams.append(info[name].pop(0))
	sems.append(info[name].pop(0))
	birthdates.append(info[name].pop(0))
	genders.append(info[name].pop(0))
	student_numbers.append(student_number[name])
	courses.append(info[name])	
	count+=1


for course_list in courses {
	line = []
	name = last_names.pop(random.randrange(len(last_names))) + ", " + \
			  first_names.pop(random.randrange(len(first_names)))
	line.append(student_numbers.pop(random.randrange(len(first_names))))
	line.append(name)
	line.append(programs.pop(random.randrange(len(programs))))
	line.append(wams.pop(random.randrange(len(wams))))
	line.append(sems.pop(random.randrange(len(sems))))
	line.append(birthdates.pop(random.randrange(len(birthdates))))
	line.append(genders.pop(random.randrange(len(gender))))
	line = "|".join(@line)
	while len(course_list) > 0:
		print course_list.pop(0), "|", line, "\n";	
		

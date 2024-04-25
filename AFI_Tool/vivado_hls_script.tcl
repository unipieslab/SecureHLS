#Copyright (C) 2023  Amalia-Artemis Koufopoulou, Athanasios Papadimitriou, Mihalis Psarakis, David Hely

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Create log file
set log_file [open "log_file.txt" "w"]

# Print info about the run - Time of start
set systemTime [clock seconds]
puts $log_file "\n\nCHECKPOINT - Design generation started at : [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"

# Set number of designs to generate

set file_start [open "./Constants/NUM_OF_START.txt" r]
set design_start [expr [gets $file_start]]
close $file_start

# Read the value of num_of_designs from NUM_OF_DESIGNS.txt
set file_num [open "./Constants/NUM_OF_DESIGNS.txt" r]
set num_of_designs [expr [gets $file_num]]
close $file_num

# Calculate design_end
set design_end [expr $design_start + $num_of_designs]

after 10000

# ----------------------------IMPORTANT---------------------------------
# If you want to check another code, go directly to code.c and code_tb.c
# Name yout top function 'top_function'

# Set project name
set project_name "Designs"

# Set project settings
open_project $project_name
set_top top_function
add_files $project_name/code.c
add_files -tb $project_name/code_tb.c -cflags "-Wno-unknown-pragmas" -csimflags "-Wno-unknown-pragmas"

# Generate number of solutions
set all_solutions {}
set i $design_start

while {$i < $design_end} {
    lappend all_solutions sol_$i
    incr i
}

# Baseline Solution (sol_0) Settings
#open_solution -reset "sol_0"
#set_part {xc7a12ti-csg325-1L}
#create_clock -period 10 -name default

# Baseline_directives is an empty file
#source "./$project_name/baseline_directives.tcl"
#file copy -force ./$project_name/baseline_directives.tcl ./$project_name/sol_0/directives.tcl 
	
#csim_design
#csynth_design
#cosim_design
#export_design

#puts $log_file "sol_0 DONE!"

# Solutions with random directives
foreach solution $all_solutions {

    #set dir $solution

    #file delete -force -- $dir

	# Solution Settings
	open_solution -reset $solution
	set_part {xc7a12ti-csg325-1L}
	create_clock -period 10 -name default
	
	# Script that generates random_directives.tcl foreach solution
	exec matlab -nosplash -nodesktop -r "run ('set_directives.m'); quit"
	
	# Give some time for matlab script to run - might be unneccesary
	after 50000
	
	# Get the file with the rand
	
	source "./$project_name/random_directives.tcl"
	
	file copy -force ./$project_name/random_directives.tcl ./$project_name/$solution/directives.tcl 
	
	# No need to repeat .c check
	#csim_design
	csynth_design
	#cosim_design
	#export_design
	
	#puts $log_file "$solution DONE!"
}
close_project

set systemTime [clock seconds]
puts $log_file "\n\nCHECKPOINT - Random solutions for code.c generated at : [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"


# Script that generates designs folders
exec matlab -nosplash -nodesktop -r "run ('create_designs_folders.m'); quit"

set systemTime [clock seconds]
puts $log_file "\n\nCHECKPOINT - Designs created at : [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"

close $log_file

after 10000 exit

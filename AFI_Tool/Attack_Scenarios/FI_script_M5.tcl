#Copyright (C) 2023  Amalia-Artemis Koufopoulou, Kalliopi Xevgeni, Ioanna Souvatzoglou, Athanasios Papadimitriou , Mihalis Psarakis, David Hely

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


# THE COMMANDS ABOVE WERE ADDED BY create_batch.m



# Print info about the run - Time of start
set systemTime [clock seconds]

# Set project name
set project_name "Designs"

set current_directory [file normalize [file dirname [info script]]]
set path [file dirname [file dirname [file dirname $current_directory]]]

set IgnoreWarning 1

# Create log file
set log_file [open ../../../log_file.txt  "a"]
set systemTime [clock seconds]
puts $log_file "\n\n	Attack on $d start at: [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"
set clock_period 10

# ------------------------------------------------------------------------------------------------------------------------------------
# 																GOLD RUN
# ------------------------------------------------------------------------------------------------------------------------------------

# Get signals from Signal_list_m1.txt

# set d C:/Users/amagi/Desktop/v2_RANDOM_SOL_GEN_FRAMEWORK/Vivado_HLS/design_1/FI

#set signallistfile [open "FI/Signal_list_m1.txt" "r"] 
#set signallistfile [open "$d/Signal_list_m1.txt" "r"] 
set signallistfile [open "$d/Signal_list.txt" "r"] 
set signallist_1 {}
while {![eof $signallistfile]} {
	set line [gets $signallistfile]
lappend signallist_1 $line
}
close $signallistfile

set gold [open "$d/gold_run.txt" "w"] 

# Start simulation for golden run

#open_vcd $d/dump.vcd

restart -quiet	
remove_forces -all

#log_vcd [get_objects -recursive *]	
	
add_force {/top_function/ap_clk} -radix hex {1 0ns} {0 5ns} -repeat_every 10ns 
add_force {/top_function/ap_rst} -radix hex {1 0ns} 
add_force {/top_function/ap_start} -radix hex {0 0ns}
run $clock_period ns

add_force {/top_function/ap_rst} -radix hex {0 0ns} 
add_force {/top_function/ap_start} -radix hex {1 0ns}	

# Important : add_force values can only be constants
# Since this script is not operational ( create_batch.m script creates the actual scrip)
# The constants will be set from there.
# This will allow for randomization of input	
add_force {/top_function/n} -radix bin {*** 0ns}

# DEMO -- Should be zero
#run $clock_period ns 

# First signal should always be DONE
set done_1 [lindex $signallist_1 0]

# set done_1_val ...

#set output_1 [lrange $signallist_1 1 end], but include 0 (done signal)
set output_1 [lrange $signallist_1 0 end]

#set out_1
set out_1 [lindex $output_1 1]

# set output_1_val {}

# Initilization time
set end_time $clock_period
set done_val_1 0
set step [expr $clock_period/2]

# Run 1 clock cycle (10 ns) till ap_done signal equals 1

while {$done_val_1 != 1} {

	run $step ns
	set done_val_1 [get_value $done_1]
	set end_time [expr {$end_time + $step}]

}

#close_vcd

# Save execution time (end_time) at dedicated file, $d
set stats_file [open "$d/stats.txt" "a"]

puts $stats_file "Execution Time: $end_time"

close $stats_file

# At this point, flag == 1 (hence done == 1), and we dan retrieve golden values for the output signals set from Signal_list_m1.txt
foreach i $output_1 {
	puts -nonewline $gold $i
	puts -nonewline $gold "\t"
	puts $gold [get_value $i]
}

close $gold

set dd [split $d {'_'}]

set dd [lindex $dd end]

set dd [split $dd {'/'}]

set dd [lindex $dd 0]

exec matlab -nosplash -nodesktop -r "addpath('$path');run('generateFaultPairs($dd,$end_time)');quit;"


# ------------------------------------------------------------------------------------------------------------------------------------
# 															FI Campaign - M5
# ------------------------------------------------------------------------------------------------------------------------------------


set out [open "$d/M5_out.txt" "w"] 

# Set headers for M5_out.txt
# Tip : \t is used as delimeter
puts -nonewline $out "Signal_1"
puts -nonewline $out "\t"

puts -nonewline $out "ClockCycle_1"
puts -nonewline $out "\t"

puts -nonewline $out "Signal_2"
puts -nonewline $out "\t"

puts -nonewline $out "ClockCycle_2"
puts -nonewline $out "\t"

puts -nonewline $out "Signal_3"
puts -nonewline $out "\t"

puts -nonewline $out "ClockCycle_3"
puts -nonewline $out "\t"

puts -nonewline $out "Signal_4"
puts -nonewline $out "\t"

puts -nonewline $out "ClockCycle_4"
puts -nonewline $out "\t"

puts -nonewline $out "Signal_5"
puts -nonewline $out "\t"

puts -nonewline $out "ClockCycle_5"
puts -nonewline $out "\t"


foreach i $output_1 {
	puts -nonewline $out $i
	puts -nonewline $out "\t"
}

puts -nonewline $out "\n"

close $out

#after 9999999
while  {![file exists "$d/M5_registers.txt"]} {

	after 30000
	puts "Waiting for M5_registers.txt...\n\n"
}

# Get victim signals from newregisters.txt
set regfile [open "$d/M5_registers.txt" "r"] 
set victim_regs_1 {}
set victim_times_1 {}
set victim_regs_2 {}
set victim_times_2 {}
set victim_regs_3 {}
set victim_times_3 {}
set victim_regs_4 {}
set victim_times_4 {}
set victim_regs_5 {}
set victim_times_5 {}

while {![eof $regfile]} {
	set line [gets $regfile]
	
	set tosplit [split $line {'--'}]

	lappend victim_regs_1 [lindex $tosplit 0]
	lappend victim_times_1 [lindex $tosplit 2]
	lappend victim_regs_2 [lindex $tosplit 4]
	lappend victim_times_2 [lindex $tosplit 6]
	lappend victim_regs_3 [lindex $tosplit 8]
	lappend victim_times_3 [lindex $tosplit 10]
	lappend victim_regs_4 [lindex $tosplit 12]
	lappend victim_times_4 [lindex $tosplit 14]
	lappend victim_regs_5 [lindex $tosplit 16]
	lappend victim_times_5 [lindex $tosplit 18]
}
close $regfile

# Last line is newline and should be removed
set victim_regs_1 [lrange $victim_regs_1 0 end-1]
set victim_times_1 [lrange $victim_times_1 0 end-1]
set victim_regs_2 [lrange $victim_regs_2 0 end-1]
set victim_times_2 [lrange $victim_times_2 0 end-1]
set victim_regs_3 [lrange $victim_regs_3 0 end-1]
set victim_times_3 [lrange $victim_times_3 0 end-1]
set victim_regs_4 [lrange $victim_regs_4 0 end-1]
set victim_times_4 [lrange $victim_times_4 0 end-1]
set victim_regs_5 [lrange $victim_regs_5 0 end-1]
set victim_times_5 [lrange $victim_times_5 0 end-1]

foreach i $victim_regs_1 ii $victim_times_1 j $victim_regs_2 jj $victim_times_2 k $victim_regs_3 kk $victim_times_3 l $victim_regs_4 ll $victim_times_4 m $victim_regs_5 mm $victim_times_5 {

	puts [format {%s	%s	%s	%s	%s	%s	%s	%s	%s	%s} $i $ii $j $jj $k $kk $l $ll $m $mm]

	set out [open "$d/M5_out.txt" "a"]
	
	puts -nonewline $out $i
	puts -nonewline $out "\t"
	puts -nonewline $out $ii
	puts -nonewline $out "\t"
	puts -nonewline $out $j
	puts -nonewline $out "\t"
	puts -nonewline $out $jj
	puts -nonewline $out "\t"
	puts -nonewline $out $k
	puts -nonewline $out "\t"
	puts -nonewline $out $kk
	puts -nonewline $out "\t"
	puts -nonewline $out $l
	puts -nonewline $out "\t"
	puts -nonewline $out $ll
	puts -nonewline $out "\t"
	puts -nonewline $out $m
	puts -nonewline $out "\t"
	puts -nonewline $out $mm
	puts -nonewline $out "\t"
	
	# First run initilization
	restart -quiet
	remove_forces -all	
	
	add_force {/top_function/ap_clk} -radix hex {1 0ns} {0 5ns} -repeat_every 10ns 
	add_force {/top_function/ap_rst} -radix hex {1 0ns} 
	add_force {/top_function/ap_start} -radix hex {0 0ns}
	run $clock_period ns
	
	add_force {/top_function/ap_rst} -radix hex {0 0ns} 
	add_force {/top_function/ap_start} -radix hex {1 0ns}		
	#add_force {/top_function/n} -radix bin {11010001 0ns} 
	
	#run $end_time ns
	
	# Second, run faulty run			
	add_force {/top_function/n} -radix bin {*** 0ns}  
			
	# Then insert first bit flip

	set fault_time_1 $ii
	set fault_ff_1 $i
	set fault_time_2 $jj
	set fault_ff_2 $j
	set fault_time_3 $kk
	set fault_ff_3 $k
	set fault_time_4 $ll
	set fault_ff_4 $l
	set fault_time_5 $mm
	set fault_ff_5 $m
	
	set remaining_time_1 [expr {$fault_time_2 - $fault_time_1}]
	set remaining_time_2 [expr {$fault_time_3 - $fault_time_2}]
	set remaining_time_3 [expr {$fault_time_4 - $fault_time_3}]
	set remaining_time_4 [expr {$fault_time_5 - $fault_time_4}]
	
	#First fault
	run [expr {$fault_time_1 - $clock_period}]ns
	
	# First Transient bit flip
	if {[get_value $fault_ff_1] == 1} {add_force $fault_ff_1 -radix hex {0 0ns} -cancel_after 10ns} else {add_force $fault_ff_1 -radix hex {1 0ns} -cancel_after 10ns}
	
	# Run to second fault
	run [expr {$remaining_time_1}]ns

	# Second Transient bit flip
	if {[get_value $fault_ff_2] == 1} {add_force $fault_ff_2 -radix hex {0 0ns} -cancel_after 10ns} else {add_force $fault_ff_2 -radix hex {1 0ns} -cancel_after 10ns}	
	
	# Run to third fault
	run [expr {$remaining_time_2}]ns
	
	# Third Transient bit flip
	if {[get_value $fault_ff_3] == 1} {add_force $fault_ff_3 -radix hex {0 0ns} -cancel_after 10ns} else {add_force $fault_ff_3 -radix hex {1 0ns} -cancel_after 10ns}	
	
	# Run to fourth fault
	run [expr {$remaining_time_3}]ns
	
	# Fourth Transient bit flip
	if {[get_value $fault_ff_4] == 1} {add_force $fault_ff_4 -radix hex {0 0ns} -cancel_after 10ns} else {add_force $fault_ff_4 -radix hex {1 0ns} -cancel_after 10ns}	
	
	# Run to fifth fault
	run [expr {$remaining_time_4}]ns
	
	# Fourth Transient bit flip
	if {[get_value $fault_ff_5] == 1} {add_force $fault_ff_5 -radix hex {0 0ns} -cancel_after 10ns} else {add_force $fault_ff_5 -radix hex {1 0ns} -cancel_after 10ns}	
	
	
	# Stuck-at bit flip
	#if {[get_value $sig_name] == 1} {add_force $sig_name -radix hex {0 0ns}} else {add_force $sig_name -radix hex {1 0ns}}
	
	# Run to first end time and get output values
	set current_time [current_time]
	set current_time [split $current_time {' '}]
	set current_time [lindex $current_time 0]
	run [expr {$end_time - $current_time}]ns
	
	# Retrieve effect on output and write on M5_out.txt
	puts -nonewline $out [get_value $done_1]
	puts -nonewline $out "\t"
	puts -nonewline $out [get_value $out_1]
	puts -nonewline $out "\t"


	puts -nonewline $out "\n"
	
	
	close $out
}

set systemTime [clock seconds]
puts $log_file "\n\n	Attack on $d ended at: [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"

close $log_file

# THE COMMANDS BELOW WERE ADDED BY create_batch.m
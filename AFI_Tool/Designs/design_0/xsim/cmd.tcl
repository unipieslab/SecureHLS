set d C:/MyWork/AFI_Tool/Designs/design_0/FI
# THE COMMANDS ABOVE WERE ADDED BY create_batch.m

# Print info about the run - Time of start
set systemTime [clock seconds]

# Set project name
set project_name "Designs"

set IgnoreWarning 1

# Create log file
set log_file [open ../../../log_file.txt  "a"]
set systemTime [clock seconds]
puts $log_file "\n\n	Attack on $d start at: [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S] --"
set clock_period 10

# ------------------------------------------------------------------------------------------------------------------------------------
# 																GOLD RUN
# ------------------------------------------------------------------------------------------------------------------------------------

# Get signals from Signal_list_m1.txt

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
	
add_force {/top_function/ap_clk} -radix hex {0 0ns} {1 5ns} -repeat_every 10ns 
add_force {/top_function/ap_rst} -radix hex {1 0ns} 
add_force {/top_function/ap_start} -radix hex {0 0ns}
run $clock_period ns

add_force {/top_function/ap_rst} -radix hex {0 0ns} 
add_force {/top_function/ap_start} -radix hex {1 0ns}	

# Important : add_force values can only be constants
# Since this script is not operational ( create_batch.m script creates the actual scrip)
# The constants will be set from there.
# This will allow for randomization of input
add_force {/top_function/n} -radix bin {11010000 0ns}

# DEMO -- Should be zero
#run $clock_period ns 

# First signal should always be DONE
set done_1 [lindex $signallist_1 0]

# set done_1_val ...

#set output_1 [lrange $signallist_1 1 end], but include 0 (done signal)
set output_1 [lrange $signallist_1 0 end]

# set output_1_val {}

# Initilization time
set end_time $clock_period
set end_flag 0
set step [expr $clock_period/2]

# Run 1 clock cycle (10 ns) till ap_done signals equals 1

while {$end_flag < 1} {

	set done_val_1 [get_value $done_1]
	
	if {$done_val_1 < 1 && $end_flag < 1} {
		set end_time [expr {$end_time + $step}]
	} elseif {$end_flag < 1} {
		set end_flag 1
	}
	
	run $step ns
	
	puts $end_time

}

#close_vcd

# Save execution time (end_time) at dedicated file, $d
set stats_file [open "$d/stats.txt" "a"]

puts $stats_file "Execution Time: [expr $end_time - $step]"

close $stats_file


# At this point, flag == 1 (hence done == 1), and we dan retrieve golden values for the output signals set from Signal_list_m1.txt
foreach i $output_1 {
	puts -nonewline $gold $i
	puts -nonewline $gold "\t"
	puts $gold [get_value $i]
}

close $gold


# ------------------------------------------------------------------------------------------------------------------------------------
# 															FI Campaign - SBF
# ------------------------------------------------------------------------------------------------------------------------------------

set out [open "$d/out.txt" "w"] 

# Set headers on out.txt
# Tip : \t is used as delimeter
puts -nonewline $out "Signal"
puts -nonewline $out "\t"

puts -nonewline $out "ClockCycle"
puts -nonewline $out "\t"


foreach i $output_1 {
	puts -nonewline $out $i
	puts -nonewline $out "\t"
}

puts -nonewline $out "\n"

close $out

# Get victim signals from registers.txt
set regfile [open "$d/registers.txt" "r"] 
set victim_regs {}

while {![eof $regfile]} {
	set line [gets $regfile]
lappend victim_regs $line
}
close $regfile

# Last line is newline and should be removed
# alter end-1 to debug
set victim_regs [lrange $victim_regs 0 end-1]

foreach sig_name $victim_regs {

	#set out [open "$d/out.txt" "w"] 
	set out [open "$d/out.txt" "a"]

	# Set the time of bit flip occurence - take into account initilization run
	set current_time $clock_period
	#set new_end_time [expr {$end_time * 2}]
	
	while {$current_time < $end_time} {
	
		puts [format {%s	%s} $sig_name $current_time]
	
		puts -nonewline $out $sig_name
		puts -nonewline $out "\t"
	
		puts -nonewline $out $current_time
		puts -nonewline $out "\t"
		
		# First run initilization
		restart -quiet
        remove_forces -all	
		
		add_force {/top_function/ap_clk} -radix hex {0 0ns} {1 5ns} -repeat_every 10ns 
		add_force {/top_function/ap_rst} -radix hex {1 0ns} 
		add_force {/top_function/ap_start} -radix hex {0 0ns}
		run $clock_period ns
		
		add_force {/top_function/ap_rst} -radix hex {0 0ns} 
		add_force {/top_function/ap_start} -radix hex {1 0ns}		
		#add_force {/top_function/n} -radix bin {11010001 0ns} 
		
		#run $end_time ns
		
		# Second, run faulty run			
		add_force {/top_function/n} -radix bin {11010000 0ns}
		
		# Then bit flip at current_time
		run [expr {$current_time - $clock_period}]ns
		
		# Insert error
		
		# Transient bit flip
		if {[get_value $sig_name] == 1} {add_force $sig_name -radix hex {0 0ns} -cancel_after 10ns} else {add_force $sig_name -radix hex {1 0ns} -cancel_after 10ns}	
		
		# Stuck-at bit flip
		#if {[get_value $sig_name] == 1} {add_force $sig_name -radix hex {0 0ns}} else {add_force $sig_name -radix hex {1 0ns}}
		
		# Lastly run till end_time 
		
		run [expr {$end_time - $current_time}] ns
		
		# Retrieve effect on output and write on out.txt
		
		foreach i $output_1 {
			puts -nonewline $out [get_value $i]
			puts -nonewline $out "\t"
		}
		
		puts -nonewline $out "\n"
		
		
		# Increase current_time by one clock cycle
		
		set current_time [expr {$current_time + $clock_period}]
		
	}
	
	close $out
}

set systemTime [clock seconds]
puts $log_file "\n\n	Attack on $d ended at: [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"

close $log_file

# THE COMMANDS BELOW WERE ADDED BY create_batch.m
quit

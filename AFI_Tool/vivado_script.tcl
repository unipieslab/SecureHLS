#Copyright (C) 2023  Amalia-Artemis Koufopoulou, Kalliopi Xevgeni, Athanasios Papadimitriou, Mihalis Psarakis, David Hely

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

# Open log file
set log_file [open "log_file.txt" "a"]

# Set project name
set project_name "Designs"

open_project Vivado_Project/Vivado_Project.xpr

set designs [glob -type d $project_name/design_*]
set di 0

#set systemTime [clock seconds]
#puts $log_file "\n\nCHECKPOINT - Design data extraction (graph - FI simulation data) start: [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"


foreach d $designs { 

	set d [file normalize $d]
	
	
	#Copy ./FI contents to each design's FI folder
	set sourceFolder "./FI"
	set destinationFolder "$d/FI"

	file delete -force $destinationFolder
	file copy -force  $sourceFolder $d

	remove_files [get_files]
	update_compile_order -fileset sources_1
	
	#add_files -norecurse Vivado_Project/top_module.vhd
	#set_property library work [get_files Vivado_Project/top_module.vhd]

	#add_files  C:/Users/amagi/Desktop/_RANDOM_SOL_GEN_FRAMEWORK/Vivado_HLS/design_0/Module/
	add_files $d/Module/
	#set_property library Module [get_files  C:/Users/amagi/Desktop/_RANDOM_SOL_GEN_FRAMEWORK/Vivado_HLS/design_0/Module/*]
	set_property library Module [get_files  $d/Module/*]
	
	after 2000
	update_compile_order -fileset sources_1
	
	set_property top top_function [current_fileset]
	
	update_compile_order -fileset sources_1
	
	set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE Default [get_runs synth_1]
	
	#add_files $d/module_2/
	#set_property library module_2 [get_files  $d/module_2/*]
	#update_compile_order -fileset sources_1
	
	synth_design -rtl -name rtl_1 -resource_sharing off
	#synth_design -rtl -name rtl_1
	
	# Write EDIF file for later
	write_edif -force $d/Graphs/design.edf
	
	# Also, write post-synthesis utilization, power and timing reports
	reset_run synth_1
	launch_runs synth_1 -jobs 12
	wait_on_run synth_1
	open_run synth_1 -name synth_1
	report_utilization -file $d/Graphs/utilization.txt
	report_power -file $d/Graphs/power_report.txt
	
	create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports -regexp -filter { NAME =~  ".*clk.*" && DIRECTION == "IN" }]
	report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -file $d/Graphs/timing_report.txt
	
	# Get designs #FFs - Save to dedicated file
	
    set_param tcl.collectionResultDisplayLimit 999999999
	set allregisters {}
	set allregisters [all_registers]
	set outfile3 [open "$d/FI/_registers.txt" "w"]
	close $outfile3
	set outfile3 [open "$d/FI/_registers.txt" "a"]
	set flipflops [split $allregisters  ]
	set countregisters [llength $flipflops]

	for {set i 0} {$i <= $countregisters} {set i [expr $i + 1]} {
		#puts -nonewline $outfile3 /sbox/
		puts -nonewline $outfile3 [lindex $flipflops [expr $i - 1]]
		puts -nonewline $outfile3 "\t"
		puts -nonewline $outfile3 "\n"
	}
	
	close $outfile3
	
		# Save #FFs at log file
	#puts $log_file "$d : -- $countregisters"
	
	# Save #FFs at dedicated file, $d
	set stats_file [open "$d/FI/stats.txt" "a"]
	
	puts $stats_file "\n		Statistics for design	\n\n"
	
	puts $stats_file "#FFs: $countregisters"

	#incr di
	close $stats_file
	
	# Export simulation files for the attack
	export_simulation -export_source_files -directory "$d/" -simulator xsim -force	
	
	
}
set systemTime [clock seconds]
puts $log_file "\n\nCHECKPOINT - Design data extraction end: [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"

close_project
exec matlab -nosplash -nodesktop -r "run ('reg_parse.m'); quit"
set systemTime [clock seconds]
puts $log_file "\n\nCHECKPOINT - register.txt files created: [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"

# Create all cmd.tcl
exec matlab -nosplash -nodesktop -r "run ('create_batch.m'); quit"
set systemTime [clock seconds]
puts $log_file "\n\nCHECKPOINT - Simulation scenarios (cmd.tcl) created: [clock format $systemTime -format %D] [clock format $systemTime -format %H:%M:%S]\n\n"

close $log_file
exit
exit











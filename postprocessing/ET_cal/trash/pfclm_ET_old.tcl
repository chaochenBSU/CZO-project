# SCRIPT TO CALCULATE SUBSURFACE STORAGE
# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4
#-----------------------------------------------------------------------------
# path to files
#-----------------------------------------------------------------------------



#-----------------------------------------------------------------------------
# Set up run info
#-----------------------------------------------------------------------------
# set filename                              "pfclm1_base1.out"
set starttime                            1
set stoptime                              336

set case_namelist [list pfclm1_base1 pfclm1_base40 pfclm2_base1 pfclm2_base40]
# set case_namelist [list pfclm1_base1]
set num_case [llength $case_namelist]
puts $num_case


for {set j 0} {$j<$num_case} {incr j} {

	puts $j
	set filename [lindex $case_namelist $j]
	puts $filename
	set file_path [format /home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/extended_simulation/outputs_$filename]
	cd $file_path
	pwd

	set calculated_ET_volume_file [open ../../postprocessing/ET_cal/ET_volume_$filename.csv w ]
	set calculated_ET_file [open ../../postprocessing/ET_cal/ET_depth_$filename.csv w ]

	for {set i $starttime} {$i <=$stoptime } {incr i} {
	    set timestep [expr $i] 
	    set fnameevap [format "$filename.out.qflx_evap_tot.%05d.pfb" $i]  
	    set fnametran [format "$filename.out.qflx_tran_veg.%05d.pfb" $i]
		puts $timestep
		#puts [pwd]
		# $fnameevap
		# puts $fnametran
		
		if {[catch { exec tclsh /home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/postprocessing/ET_cal/pfb_reading_fun.tcl $fnameevap} result_or_errormsg]} {
				puts $result_or_errormsg 
				puts $calculated_ET_file "$timestep, 0 "
				puts "$timestep not calculated"
		} else {
			set tran [pfload $fnametran]
			puts $tran
			set evap [pfload $fnameevap]	
		    set total_evap_storage [pfsum $evap]
		    set surface_evap_volume [expr {$total_evap_storage}]
		    set surface_evap_depth [expr {$total_evap_storage/30 /30 /198 /198}]

		    set total_tran_storage [pfsum $tran]
		    set surface_tran_volume [expr {$total_tran_storage}]
		    set surface_tran_depth [expr {$total_tran_storage/30 /30 /198 /198}]

		    puts $calculated_ET_volume_file "$timestep, [expr $surface_volume_depth + $surface_volume_depth]"
		    puts $calculated_ET_file "$timestep, [expr $surface_evap_depth + $surface_tran_depth]"
		    puts [format "ET_depth  \t\t\t\t : %.16e"   [expr $surface_evap_depth + $surface_tran_depth]]
		    #-----------------------------------------------------------------------------       
		    # Clean up to avoid memory leaks...
		    #-----------------------------------------------------------------------------
		    pfdelete $evap
		    pfdelete $tran    
		    unset evap
		    unset tran
		}


	}
	close $calculated_ET_file
	puts "...DONE."
}
	#-----------------------------------------------------------------------------
	# calculation
	#-----------------------------------------------------------------------------



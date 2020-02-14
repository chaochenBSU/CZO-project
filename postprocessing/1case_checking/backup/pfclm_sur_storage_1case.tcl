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
set starttime                            0
set stoptime                              336

# set case_namelist [list pfclm1_base1 pfclm1_base40 pfclm2_base1 pfclm2_base40]
set case_namelist [list pfclm2_base40]
set num_case [llength $case_namelist]
puts $num_case


for {set j 0} {$j<$num_case} {incr j} {

	puts $j
	set filename [lindex $case_namelist $j]
	puts "$filename"
	set file_path [format /home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/extended_simulation/outputs_pfclm2_base40_s]
	cd $file_path

	set mask [pfload $filename.out.mask.pfb]

	set calculated_obs_file [open ../../postprocessing/surfacestorage_cal/surface_storage_depth_$filename.csv w ]

	set top [pfcomputetop $mask]

	for {set i $starttime} {$i <=$stoptime } {incr i} {
	    set timestep [expr $i] 
	    set fnamepress [format "$filename.out.press.%05d" $i]
	    set pressure [pfload $fnamepress.pfb]
	    set surface_storage [pfsurfacestorage $top $pressure]
	    set total_surface_storage [pfsum $surface_storage]
	    set surface_storage_depth [expr {$total_surface_storage/30 /30 /198 /198}]

	    puts $calculated_obs_file "$timestep, $surface_storage_depth"
	    puts [format "Surface storage\t\t\t\t : %.16e"   $surface_storage_depth]
	    #-----------------------------------------------------------------------------       
	    # Clean up to avoid memory leaks...
	    #-----------------------------------------------------------------------------
	    pfdelete $pressure    
	    unset pressure   

	}
	puts "...DONE."
}
	#-----------------------------------------------------------------------------
	# calculation
	#-----------------------------------------------------------------------------



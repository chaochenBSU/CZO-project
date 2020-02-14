#---------------------------------------------------------
# Import the ParFlow TCL package
#---------------------------------------------------------
lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*

pfset     FileVersion    4


# Tests 
#

source pftest.tcl
# set verbose 0
set passed 1
lassign $argv runname stoptime TimingInfo_DumpInterval


# set TimingInfo_DumpInterval 1
# set stoptime 100

# set case_namelist [list pfclm2_base40]
set case_namelist [list $runname]
set num_case [llength $case_namelist]
puts $num_case

for {set j 0} {$j < $num_case} {incr j} {
	puts $j
	set case_name [lindex $case_namelist  $j]

	if {$case_name == "pfclm1_base1" || $case_name == "pfclm1_base40"} {
		set slope_name  "DEMfil_WS1_74"
		} else {
			set slope_name  "WS2_SR"
		}
	puts $slope_name
##########################################
##########################################
##########################################
########## change the name here ##########
	set input_path [format ../../extended_simulation/outputs_pfclm2_base40_s]
	puts $input_path
	set runname [format $case_name.out]



	#########################################################################
	################## write total water balance into each excel
	set calculated_surface_storage_file       [open [format ./csv/total_surface_storage_$case_name.csv] w ]
	set calculated_subsurface_storage_file    [open [format ./csv/total_subsurface_storage_$case_name.csv] w ]
	set calculated_total_water_file           [open [format ./csv/total_water_in_domain_$case_name.csv] w ]
	set calculated_total_surface_runoff_file  [open [format ./csv/total_surface_runoff_$case_name.csv] w ]
	set calculated_water_balance_diff_file    [open [format ./csv/water_balance_diff_$case_name.csv] w ]
	set calculated_expected_difference_file   [open [format ./csv/expected_difference_$case_name.csv] w ]
	set calculated_EvapTrans_file			  [open [format ./csv/ET_$case_name.csv] w ]
	##################################################################################
	set filename [format "%s/%s.sx.pfb" $input_path $slope_name]
	set slope_x	[pfload $filename]

	set filename [format "%s/%s.sy.pfb"  $input_path $slope_name]
	puts $filename
	set slope_y          [pfload $filename]

	set filename [format "/home/chaochen/payette/chaochen/CZO/Chao/Demonstration_example/landlab_Const.Saprolite/preprocessing/writing_product/mannings.pfb" $input_path $runname]
	set mannings         [pfload $filename]
	# set mannings  5.52e-6

	set filename [format "%s/%s.specific_storage.pfb" $input_path $runname]
	set specific_storage [pfload $filename]

	set filename [format "%s/%s.porosity.pfb" $input_path $runname]
	set porosity         [pfload $filename]

	set filename [format "%s/%s.mask.pfb" $input_path $runname]
	set mask             [pfload $filename]

	set top              [pfcomputetop $mask]

	# set surface_area_of_domain [expr [pfget ComputationalGrid.DX] * [pfget ComputationalGrid.DY] * [pfget ComputationalGrid.NX] * [pfget ComputationalGrid.NY]]
	set surface_area_of_domain [expr 198 * 198 * 30 * 30]
	set prev_total_water_balance 0.0


	source time_series_fun.tcl
}


    
for {set i 0} {$i <= $stoptime} {incr i} {
	puts "======================================================"
	puts "Timestep $i"
	puts "======================================================"

	set total_water_in_domain 0.0
	##########################################################################
	########################################################################## compute the surface storage
	set filename [format "%s/%s.press.%05d.pfb" $input_path $runname $i]
	# puts $filename
	set pressure [pfload $filename]
	set surface_storage [pfsurfacestorage $top $pressure]
	pfsave $surface_storage -silo "./silo/$case_name/surface_storage.$i.silo"

	set total_surface_storage [pfsum $surface_storage]
	puts [format "Surface storage\t\t\t\t\t : %.16e" $total_surface_storage]
	puts $calculated_surface_storage_file "$i,$total_surface_storage"  
	
	set total_water_in_domain [expr $total_water_in_domain + $total_surface_storage]
	set filename [format "%s/%s.satur.%05d.pfb" $input_path $runname $i]
	set saturation [pfload $filename]
	##########################################################################
	########################################################################## compute the water table
	set water_table_depth [pfwatertabledepth $top $saturation]
	pfsave $water_table_depth -silo "./silo/$case_name/water_table_depth.$i.silo"

	##########################################################################
	########################################################################## compute the subsurface storage, incompressible and compressible
	set subsurface_storage [pfsubsurfacestorage $mask $porosity $pressure $saturation $specific_storage]
	pfsave $subsurface_storage -silo "./silo/$case_name/subsurface_storage.$i.silo"
	set total_subsurface_storage [pfsum $subsurface_storage]
	puts [format "Subsurface storage\t\t\t\t : %.16e" $total_subsurface_storage]
	puts $calculated_subsurface_storage_file "$i,$total_subsurface_storage"
    set total_water_in_domain [expr $total_water_in_domain + $total_subsurface_storage]

	puts [format "Total water in domain\t\t\t\t : %.16e" $total_water_in_domain]
	puts $calculated_total_water_file "$i,$total_water_in_domain"
	puts ""

	##########################################################################
	########################################################################## compute the runoff flowing out of the doman
	set total_surface_runoff 0.0
	if { $i > 0} {
		# ET
		set curr_path [pwd]
		puts $curr_path
		cd $input_path
		set filename [format "%s.evaptrans.%05d.silo" $runname $i]
		set evaptrans [pfload $filename]
		set total_evaptrans [pfsum $evaptrans]
		puts "EvapTrans : $total_evaptrans"
		puts $calculated_EvapTrans_file "$i,$total_evaptrans"
		cd $curr_path

		# surface runoff
		set surface_runoff [pfsurfacerunoff $top $slope_x $slope_y $mannings $pressure]
		pfsave $surface_runoff -silo "./silo/$case_name/surface_runoff.$i.silo"
		set total_surface_runoff [expr [pfsum $surface_runoff] * $TimingInfo_DumpInterval]
	    puts [format "Surface runoff from pftools\t\t\t : %.16e" $total_surface_runoff]
	    puts $calculated_total_surface_runoff_file "$i,$total_surface_runoff"

	    #overlamd flow, sould equal to computed surface runoff
		set curr_path [pwd]
		cd $input_path
		set filename [format "%s.overlandsum.%05d.silo" $runname $i]
		set surface_runoff2 [pfload $filename]
		set total_surface_runoff2 [pfsum $surface_runoff2]
		cd $curr_path
		
		if ![pftestIsEqual $total_surface_runoff $total_surface_runoff2 "Surface runoff comparison" ] {
		    set passed 0
		}

	    set bc_flux 0.0000000000000000e+00
	    set boundary_flux [expr $bc_flux * $surface_area_of_domain * $TimingInfo_DumpInterval]
		puts [format "BC flux\t\t\t\t\t\t : %.16e" $boundary_flux]

	    # Note flow into domain is negative
	    set expected_difference [expr $boundary_flux + $total_surface_runoff]
		puts [format "Total Flux\t\t\t\t\t : %.16e" $expected_difference]
		puts $calculated_expected_difference_file "$i,$expected_difference" 
	    puts [format "Diff from prev total\t\t\t\t : %.16e" [expr $total_water_in_domain - $prev_total_water_balance]]
	
		if [expr $expected_difference != 0.0] {
		    set percent_diff [expr (abs(($prev_total_water_balance - $total_water_in_domain) - $expected_difference)) / abs($expected_difference) * 100]
			puts [format "Percent diff from expected difference\t\t : %.12e" $percent_diff]
		}

		set expected_water_balance [expr $prev_total_water_balance - $expected_difference]
		set percent_diff [expr abs(($total_water_in_domain - $expected_water_balance)) / $expected_water_balance * 100]
		# if $verbose {
		    puts [format "Percent diff from expected total water sum\t : %.12e" $percent_diff]
		    puts $calculated_water_balance_diff_file "$i,$percent_diff"
		# }

		if [expr $percent_diff > 0.05] {
		    puts "Error: Water balance is not correct"
		    set passed 0
		}
	}
	set prev_total_water_balance [expr $total_water_in_domain]
}

# if $passed {
#     puts "$runname : PASSED"
# } {
#     puts "$runname : FAILED"
# }



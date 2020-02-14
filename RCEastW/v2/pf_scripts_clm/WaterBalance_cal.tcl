#---------------------------------------------------------
# Import the ParFlow TCL package
#---------------------------------------------------------
lappend auto_path $env(PARFLOW_DIR)/bin 
package require parflow
namespace import Parflow::*#

pfset FileVersion 4


# Tests 
#
# source pftest.tcl
set verbose 0
set passed 1

#########################################################################
################## write total water balance into each excel
set calculated_surface_storage_file       [open ./total_surface_storage.csv w ]
set calculated_subsurface_storage_file    [open ./total_subsurface_storage.csv w ]
set calculated_total_water_file           [open ./total_water_in_domain.csv w ]
set calculated_total_surface_runoff_file  [open ./total_surface_runoff.csv w ]
set calculated_water_balance_diff_file    [open ./water_balance_diff.csv w ]
set calculated_expected_difference_file   [open ./expected_difference.csv w ]
##################################################################################
set slope_x          [pfload $runname.out.slope_x.silo]
set slope_y          [pfload $runname.out.slope_y.silo]
set mannings         [pfload $runname.out.mannings.silo]
set specific_storage [pfload $runname.out.specific_storage.silo]
set porosity         [pfload $runname.out.porosity.silo]

set mask             [pfload $runname.out.mask.silo]
set top              [pfcomputetop $mask]

set surface_area_of_domain [expr [pfget ComputationalGrid.DX] * [pfget ComputationalGrid.DY] * [pfget ComputationalGrid.NX] * [pfget ComputationalGrid.NY]]

set prev_total_water_balance 0.0

# for {set i 0} {$i <= 19} {incr i} {
for {set i 0} {$i <= $stoptime} {incr i} {
    if $verbose {
	puts "======================================================"
	puts "Timestep $i"
	puts "======================================================"
    }
    set total_water_in_domain 0.0

    set filename [format "%s.out.press.%05d.pfb" $runname $i]
    set pressure [pfload $filename]
    set surface_storage [pfsurfacestorage $top $pressure]
    pfsave $surface_storage -silo "surface_storage.$i.silo"
    set total_surface_storage [pfsum $surface_storage]
    if $verbose {
	puts [format "Surface storage\t\t\t\t\t : %.16e" $total_surface_storage]
	puts $calculated_surface_storage_file "$i,$total_surface_storage"  
    }
    set total_water_in_domain [expr $total_water_in_domain + $total_surface_storage]

    set filename [format "%s.out.satur.%05d.pfb" $runname $i]
    set saturation [pfload $filename]

    set water_table_depth [pfwatertabledepth $top $saturation]
    pfsave $water_table_depth -silo "water_table_depth.$i.silo"

    set subsurface_storage [pfsubsurfacestorage $mask $porosity $pressure $saturation $specific_storage]
    pfsave $subsurface_storage -silo "subsurface_storage.$i.silo"
    set total_subsurface_storage [pfsum $subsurface_storage]
    if $verbose {
	puts [format "Subsurface storage\t\t\t\t : %.16e" $total_subsurface_storage]
	puts $calculated_subsurface_storage_file "$i,$total_subsurface_storage"

    }
    set total_water_in_domain [expr $total_water_in_domain + $total_subsurface_storage]

    if $verbose {
	puts [format "Total water in domain\t\t\t\t : %.16e" $total_water_in_domain]
	puts $calculated_total_water_file "$i,$total_water_in_domain"
	puts ""
    }

    set total_surface_runoff 0.0
    if { $i > 0} {
	set surface_runoff [pfsurfacerunoff $top $slope_x $slope_y $mannings $pressure]
	pfsave $surface_runoff -silo "surface_runoff.$i.silo"
	set total_surface_runoff [expr [pfsum $surface_runoff] * [pfget TimingInfo.DumpInterval]]
	if $verbose {
	    puts [format "Surface runoff from pftools\t\t\t : %.16e" $total_surface_runoff]
	}

	set filename [format "%s.out.overlandsum.%05d.silo" $runname $i]
	set surface_runoff2 [pfload $filename]
	set total_surface_runoff2 [pfsum $surface_runoff2]
	if $verbose {
	    puts [format "Surface runoff from pfsimulator\t\t\t : %.16e" $total_surface_runoff2]
		puts $calculated_total_surface_runoff_file "$i,$total_surface_runoff,$total_surface_runoff2"    
	}
	
	if ![pftestIsEqual $total_surface_runoff $total_surface_runoff2 "Surface runoff comparison" ] {
	    set passed 0
	}
    }

 #    if [expr $i < 1] {
	# set bc_index 0
 #    } elseif [expr $i > 0 && $i < 7] {
	# set bc_index [expr $i - 1]
 #    } {
	# set bc_index 6
 #    }
    # set bc_flux [pfget Patch.z-upper.BCPressure.$bc_index.Value]
    set bc_flux [pfget Patch.z-upper.BCPressure.all.Value]

    set boundary_flux [expr $bc_flux * $surface_area_of_domain * [pfget TimingInfo.DumpInterval]]
    if $verbose {
	puts [format "BC flux\t\t\t\t\t\t : %.16e" $boundary_flux]
    }

    # Note flow into domain is negative
    set expected_difference [expr $boundary_flux + $total_surface_runoff]
    if $verbose {
	puts [format "Total Flux\t\t\t\t\t : %.16e" $expected_difference]
	puts $calculated_expected_difference_file "$i,$expected_difference" 
    }

    if { $i > 0 } {

	if $verbose {
	    puts ""
	    puts [format "Diff from prev total\t\t\t\t : %.16e" [expr $total_water_in_domain - $prev_total_water_balance]]
	}

	if [expr $expected_difference != 0.0] {
	    set percent_diff [expr (abs(($prev_total_water_balance - $total_water_in_domain) - $expected_difference)) / abs($expected_difference) * 100]
	    if $verbose {
		puts [format "Percent diff from expected difference\t\t : %.12e" $percent_diff]

	    }
	}

	set expected_water_balance [expr $prev_total_water_balance - $expected_difference]
	set percent_diff [expr abs(($total_water_in_domain - $expected_water_balance)) / $expected_water_balance * 100]
	if $verbose {
	    puts [format "Percent diff from expected total water sum\t : %.12e" $percent_diff]
	    puts $calculated_water_balance_diff_file "$i,$percent_diff"
	}

	if [expr $percent_diff > 0.005] {
	    puts "Error: Water balance is not correct"
	    set passed 0
	}

    }

    set prev_total_water_balance [expr $total_water_in_domain]
}

if $verbose {
    puts "\n\n"
}

if $passed {
    puts "$runname : PASSED"
} {
    puts "$runname : FAILED"
}


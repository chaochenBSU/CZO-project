# SCRIPT TO CALCULATE SUBSURFACE STORAGE
# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4
#-----------------------------------------------------------------------------
# path to files
#-----------------------------------------------------------------------------

cd ../outputs2

#-----------------------------------------------------------------------------
# Set up run info
#-----------------------------------------------------------------------------
set filename                              "pf_sythetic2.out"
set starttime                            0
set stoptime                              31
#-----------------------------------------------------------------------------
# calculation
#-----------------------------------------------------------------------------

set calculated_obs_file [open RME_gw_storage_2.csv w ]
set specific_storage [pfload $filename.specific_storage.pfb]
set porosity [pfload $filename.porosity.pfb]
set mask [pfload $filename.mask.pfb]
set top [pfcomputetop $mask]

for {set i $starttime} {$i <=$stoptime } {incr i} {
    set timestep [expr $i*24] 
    set fnamesatur [format "$filename.satur.%05d" $i]
    set fnamepress [format "$filename.press.%05d" $i]
    set saturation [pfload $fnamesatur.pfb]
    set pressure [pfload $fnamepress.pfb]
    set subsurface_storage [pfsubsurfacestorage $mask $porosity \
    $pressure $saturation $specific_storage]
    set surface_storage [pfsurfacestorage $top $pressure]
    set total_subsurface_storage [pfsum $subsurface_storage]
    set total_surface_storage [pfsum $surface_storage]
    puts $calculated_obs_file "$timestep,$total_subsurface_storage, $total_surface_storage"
    puts $i
    puts [format "Subsurface storage\t\t\t\t : %.16e %.16e"  $total_subsurface_storage $total_surface_storage]
    
    #-----------------------------------------------------------------------------       
    # Clean up to avoid memory leaks...
    #-----------------------------------------------------------------------------
    
    pfdelete $pressure    
    unset pressure
    pfdelete $saturation 
    unset saturation    

}
puts "...DONE."

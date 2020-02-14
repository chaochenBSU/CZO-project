 # SCRIPT TO CALCULATE streamflow
# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4
#-----------------------------------------------------------------------------
# path to files
#-----------------------------------------------------------------------------

cd ../outputs_pfclm2
#-----------------------------------------------------------------------------
# Set up run info
set filename                              "pfclm_sythetic2.out"
set starttime                             0
set stoptime                              32

#Set the location 
set Xloc 0 
set Yloc 0
set Zloc 11
 

set calculated_strmflw_file [open Pointed_strmflow_Daily2.csv w ]
#This should be a z location on the surface of your domain
#Set the grid dimension and Mannings roughness coefficient 
set dx 1 
set n 5.52e-6

set fnameslopex [format "DEMfil.sx.pfb"]
set slopex [pfload $fnameslopex] 
puts $slopex

set fnameslopey [format "DEMfil.sy.pfb"] 
set slopey [pfload $fnameslopey] 

set sx [pfgetelt $slopex $Xloc $Yloc 0] 
set sy [pfgetelt $slopey $Xloc $Yloc 0]


set S [expr ($sx**2+$sy**2)**0.5]
puts $sx
puts $sy
puts $S

#Get the slope at the point 
for {set i $starttime} {$i <=$stoptime } {incr i} {

	set timestep [expr $i*24] 

#Get the pressure at the point :
	set fnamepress [format "$filename.press.%05d" $i]
	set press [pfload $fnamepress.pfb] 
	set P [pfgetelt $press $Xloc $Yloc $Zloc]

#If the pressure is less tha n zero # set to zero  
	if {$P < 0} { set P 0 } 
	set QT [expr ($dx/$n)*($S**0.5)*($P**(5./3.))]

	puts $i
	puts $calculated_strmflw_file "$timestep,$QT" 
	puts [format "printed streamflow\t\t\t\t : %.16e" $QT]


	# -----------------------------------------------------------------------------       
    # Clean up to avoid memory leaks...
    #-----------------------------------------------------------------------------
    
    pfdelete $press    
    # unset pressure 
	
}

puts "...DONE."
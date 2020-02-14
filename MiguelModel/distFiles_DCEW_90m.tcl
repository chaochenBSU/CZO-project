# SCRIPT TO DISTRIBUTE DCEW FORCING DATA

# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#-----------------------------------------------------------------------------
# Set up run info
#-----------------------------------------------------------------------------
#set rundir                               .
set metdir				                  "../../WRF-Data/WRF-ESMF"
set starttime                             0.0
set stoptime                              760


#-----------------------------------------------------------------------------
# Processor topology (P=x-direction,Q=y-direction,R=z-direction)
#-----------------------------------------------------------------------------
pfset Process.Topology.P                  8
pfset Process.Topology.Q                  7 
pfset Process.Topology.R                  1


#-----------------------------------------------------------------------------
# Run test
#-----------------------------------------------------------------------------
puts " "
puts "Distributing input files..."
pfset ComputationalGrid.NX                105 
pfset ComputationalGrid.NY                100 
pfset ComputationalGrid.NZ		  1

#distribute 2D Met input files
array set vars {
     v1	NLDAS.DSWR. 
     v2 NLDAS.DLWR.
     v3 NLDAS.APCP.
     v4 NLDAS.Temp.
     v5 NLDAS.UGRD.
     v6 NLDAS.VGRD.
     v7 NLDAS.Press.
     v8 NLDAS.SPFH.
}
#foreach name [array names vars] {
#	for {set i 0} {$i < $stoptime+1} {incr i} {
#        set t1 [expr $i*100+1]
#        set t2 [expr $t1+99]
#    	pfdist [format "$metdir/$vars($name)%06d_to_%06d.pfb" $t1 $t2]
#	puts "Creating $vars($name) at t: $i"
foreach name [array names vars] {
	for {set i 0} {$i < $stoptime+1} {incr i} {
    	pfdist [format "$metdir/$vars($name)%06d.pfb" $i]
	puts "Creating $vars($name) at t: $i"
	}	
}

#-----------------------------------------------------------------------------
# Undistribute files
#-----------------------------------------------------------------------------
#pfundist $runname
#pfundist parflow_input/DCEW.sx.pfb
#pfundist parflow_input/DCEW.sy.pfb
#pfundist lw.geo_indi.pfb
#foreach name [array names vars] {
#	for {set i 0} {$i < $stoptime+1} {incr i} {
#    	pfundist [format "$metdir/$vars($name)%06d.pfb" $i]
#	}	
#}


lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

# Script to convert soil indicator ASCII to binary pfb and silo files
# Example run: tclsh convert.tcl DCEW_30m 315 300 20 0.0 0.0 -20.0 30.0 30.0 1

set fname [lindex $argv 0]
set nx [lindex $argv 1]
set ny [lindex $argv 2]
set nz [lindex $argv 3]
set x0 [lindex $argv 4]
set y0 [lindex $argv 5]
set z0 [lindex $argv 6]
set dx [lindex $argv 7]
set dy [lindex $argv 8]
set dz [lindex $argv 9]

set asciiname    "$fname.indi.sa"
set indi     [pfload $asciiname]

eval [format "pfsetgrid { %d %d %d} {%f %f %f} {%f %f %f} %s " $nx $ny $nz $x0 $y0 $z0 $dx $dy $dz {$indi}]
#pfsetgrid {315 300 20} {0.0 0.0 -20.0} {30.0 30.0 1} $indi
# pfsave $indi -silo "$fname.indi.silo"
# pfsave $indi -pfb  "$fname.indi.pfb"
pfsave $indi -silo "$fname.200mthick.indi.silo"
pfsave $indi -pfb  "$fname.200mthick.indi.pfb"

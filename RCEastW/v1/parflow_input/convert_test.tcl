lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

# Script to convert soil indicator ASCII to binary pfb and silo files

set asciiname    "RCMEast_EPGS32611.dem.sa"
set fn     [pfload $asciiname]

pfsave $fn -silo "RCMEast_EPGS32611.dem.silo"

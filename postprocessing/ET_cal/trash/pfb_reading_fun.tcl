# SCRIPT TO read PFB file
# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

# set tran [pfload $fnametran]
set evap [pfload [lindex $argv 0]]	
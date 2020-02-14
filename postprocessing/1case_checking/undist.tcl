
set tcl_precision 17

#
# Import the ParFlow TCL package
#
lappend auto_path $env(PARFLOW_DIR)/bin
package require parflow
namespace import Parflow::*

# run like this: 
# $ tclsh undist.tcl ParflowRunName start_time stop_time
# where ParflowRunName is the runname of the simulation
# start_time is the starting output timestep number
# stop_time is the ending output timestep number
lassign $argv runname StartTime StopTime

 
# pfundist [append xslope $runname "_Str3Ep0_smth.rvth_1500.mx0.5.mn5.sec0.up_slopex.pfb"]
# pfundist [append yslope $runname "_Str3Ep0_smth.rvth_1500.mx0.5.mn5.sec0.up_slopey.pfb"]
# pfundist [append pme_file $runname "_PME.pfb"]
# pfundist [append indicator_file $runname "_3d-grid.v3.pfb"]
cd "../../extended_simulation/outputs_pfclm2_base40_s"
set runname "pfclm2_base40"
# set StartTime 1
# set StopTime 336

# pfundist $runname.out.specific_storage.pfb
# pfundist $runname.out.perm_x.pfb
# pfundist $runname.out.perm_y.pfb
# pfundist $runname.out.perm_z.pfb
# pfundist $runname.out.porosity.pfb
# pfundist $runname.out.mask.pfb

#possible soil vars
# satur press obf et
# set var [list "satur" "press"] 

# list of all CLM vars
set clm [list "eflx_lh_tot" "qflx_evap_soi" "swe_out" "eflx_lwrad_out" "qflx_evap_tot" "t_grnd" "eflx_sh_tot" "qflx_evap_veg" "t_soil" "eflx_soil_grnd" "qflx_infl" "qflx_evap_grnd" "qflx_tran_veg" ]

# loop over each time step 
 for {set i $StartTime} { $i <= $StopTime } {incr i} { 
  set step [format "%05d" $i]
  puts $step
	# loop over each clm variable
	foreach clm_var $clm {
		puts $clm_var
        pfundist $runname.out.$clm_var.$step.pfb
    }
	
	# loop over each soil variable
	# foreach soil_var $var {
	# 	pfundist $runname.out.$soil_var.$step.pfb
	# }
}


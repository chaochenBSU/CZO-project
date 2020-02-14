# module load slurm intel/mpi/64/2017/5.239 intel/mkl/64/2017/5.239 intel/compiler/64/2017/17.0.5 parflow/intel/3.2.0
# export PARFLOW_DIR=/cm/shared/apps/parflow/intel/3.2.0

 lappend auto_path $env(PARFLOW_DIR)/bin
 package require parflow
 namespace import Parflow::*


#set ni  5219
#set nf  5229
#set ni  0
#set nf  5

set ni  [lindex $argv 0]
set nf  [lindex $argv 1]
set va  [lindex $argv 2]

#set va "press"

#set fname  "press.init"
#set inpath [format "./pfbfiles/drainage_experiment_ICPress_s03/%s" $va]
#set inpath "./pfbfiles/drainage_experiment_ICPress_s02/$va"
# set inpath "../Parflow_Preprocessing/clm_input/Distributed_station166_met_2D_1month"
set inpath "../outputs_pfclm1"

#set outpath [format "./silofile/drainage_experiment_ICPress_s03/%s" $va]
#set outpath "./silofiles/drainage_experiment_ICPress_s02/$va"
# set outpath "./outputs_1soil_3D/oneVegeType"
# set outpath "../Parflow_Preprocessing/clm_input/Distributed_station166_met_2D_1month_silo"
set outpath "../outputs_pfclm1"

#set filename [format "pf_DCEW_30m.out.%s" $va]
#set filename "pf_DCEW_30m.out.$va"
set filename "pfclm_sythetic1.out.$va"
# set filename "NLDAS.$va"


for {set i $ni} {$i < $nf} {incr i} {
    set fname [format "$filename.%05d" $i]
    puts $inpath
    set pfbfile [pfload $inpath/$fname.pfb]
    puts "$inpath/$fname.pfb"
    pfsave $pfbfile -silo "$outpath/$fname.silo"
    # pfsave $pfbfile -sa "$outpath/$fname.sa"


    puts [format "$filename.%05d.silo ...created!" $i]
    #----------------------------------------------------    
    # Clean up to avoid memory leaks...
    #----------------------------------------------------
    pfdelete $pfbfile
    unset pfbfile
}

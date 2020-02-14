#!/bin/bash
#
# Submit command is:  qsub Parflow-PBS.bash
#
# Set your Job Name
#PBS -N PFclm-iuc-np112
#
# Join STDOut and STDError
#PBS -j oe
#
# Request a specfic queue
#PBS -q iuc
#
# Resource Allocation Default is ncpus=16:mpiprocs=16 
#PBS -l select=4:ncpus=36:mpiprocs=36
#PBS -l walltime=300:00:00
#
###PBS -W group_list=cmsupport
#PBS -P project=parflowclm
#
# Load Source System Default Modules 
echo "Sourcing (loading) default modules \n"
source /etc/profile.d/modules.sh

# Add Modules You Need
echo "Adding required job modules \n"
module load GCC/4.9.3 OpenMPI/1.8.7-GCC-4.9.3

# Environment variables
export PARFLOW_BASE_DIR=~/parflow
export PARFLOW_VERSION=3.3.1
export PARFLOW_DIR=$PARFLOW_BASE_DIR/$PARFLOW_VERSION/install
export PARFLOW_LIBS="$PARFLOW_BASE_DIR/PARFLOW_LIBS"
export OMP_NUM_THREADS=1

# Use Current Working Directory
cd $PBS_O_WORKDIR

#PBS -v PATH,LD_LIB_PATH,PARFLOW_DIR,OMP_NUM_THREADS
printenv | grep PARFLOW
module li
echo "******************* Starting the MPI process *******************"
echo "================================================================"
echo Time is $(date)
echo Running on host $(hostname)
echo PBS_JOBID=$PBS_JOBID
echo PBS_QUEUE=$PBS_QUEUE
echo PBS_SHELL=$PBS_O_SHELL
echo PBS_HOST=$PBS_O_HOST
echo PBS_WORKDIR=$PBS_O_WORKDIR
echo PBS_ENVIRONMENT=$PBS_ENVIRONMENT
echo LOADEDMODULES=$LOADEDMODULES
echo MPI_HOME=$MPI_HOME
echo "================================================================"

# Use MPIRUN To Process The Job
echo "***** Starting the MPI process \n"
# get the time just before job runs (integer assignment)
let start_time=$(date "+%-s")
# mpirun -np 16 -v --mca btl openib,sm,self parflow $PBS_O_WORKDIR/pfclm_DCEW_30m.tcl
# mpirun -v --mca btl openib,sm,self parflow $PBS_O_WORKDIR/pfclm_DCEW_30m.tcl
# mpirun -v --mca btl openib,sm,self parflow pfclm_DCEW_30m.tcl
tclsh  $PBS_O_WORKDIR/pfclm_synthetic1_base1.tcl
# get the time just after job runs
let end_time=$(date "+%-s")
# get run time for the job (arithmetic evaluation)
run_time=$(( end_time - start_time ))

# create output string
timing_output="Elapsed time in seconds:  $run_time"

# create timing file, append runtime string
echo $timing_output >> parflow_runtime.log

#!/bin/bash
#
#SBATCH -J Parflow_D_test       			# job name
#SBATCH -o log_parflow_run.o%j   		 	# output and error file name (%j expands to jobID)
#SBATCH -n 144       					# number of cores total
#SBATCH -p defq          				# queue (partition) -- normal, development, etc.
#SBATCH -t 360:00:00      				# run time (hh:mm:ss)
#SBATCH --mail-type=END,FAIL    			# notifications for job done & fail
#SBATCH --mail-user=cchen@boisestate.edu        	# send-to address
module load slurm intel/mpi/64/2017/5.239 intel/mkl/64/2017/5.239 intel/compiler/64/2017/17.0.5 parflow/intel/3.2.0
export PARFLOW_DIR=/cm/shared/apps/parflow/intel/3.2.0
# export LD_LIBRARY_PATH=/home/maguayo/apps/tcl-intel/lib:$LD_LIBRARY_PATH
# export LD_LIBRARY_PATH=/home/maguayo/parflow/v320/PARFLOW_LIBS/silo-4.9.1/lib:$LD_LIBRARY_PATH
# export LD_LIBRARY_PATH=/home/maguayo/parflow/v320/PARFLOW_LIBS/hypre-2.10.1/lib:$LD_LIBRARY_PATH
Name_tcl="pf_step1.tcl"
tclsh $Name_tcl  

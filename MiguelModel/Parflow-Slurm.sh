#!/bin/bash
#
#SBATCH -J Parflow_CLM_WRF     			# job name
#SBATCH -o log_parflow_run.o%j   		 	# output and error file name (%j expands to jobID)
#SBATCH -n 28         					# number of cores per node
#SBATCH -N 2             				# number of nodes
#SBATCH -p defq          				# queue (partition) -- normal, development, etc.
#SBATCH -t 120:00:00      				# run time (hh:mm:ss)
#SBATCH --mail-type=END,FAIL    			# notifications for job done & fail
#SBATCH --mail-user=miguelaguayo@u.boisestate.edu 	# send-to address
module load slurm intel/mpi/64 intel/mkl/64 intel/compiler/64
export LD_LIBRARY_PATH=/home/maguayo/apps/tcl-intel/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/maguayo/parflow/v320/PARFLOW_LIBS/silo-4.9.1/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/maguayo/parflow/v320/PARFLOW_LIBS/hypre-2.10.1/lib:$LD_LIBRARY_PATH
export PARFLOW_DIR=/home/maguayo/parflow/v320
tclsh pfclmwrf_DCEW_90m_20L_10sl.tcl

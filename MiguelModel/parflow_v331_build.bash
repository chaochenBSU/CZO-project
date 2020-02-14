#!/bin/bash

#
# ./ParFlow_Build.bash
#

export PARFLOW_BASE_DIR=~/parflow
export PARFLOW_VERSION=v331
export PARFLOW_SCRIPT_DIR=$(dirname $(readlink -f $0))   # get location of where swcript was run from.  /cm/shared/scripts...

#################################################################
# check for current version install
#################################################################
if [ -d $PARFLOW_BASE_DIR ]; then
        echo "An existing Parflow Base Directory found, Parflow will build under this."

        if [ -d $PARFLOW_BASE_DIR/$PARFLOW_VERSION ]; then
                echo "***************  WARNING  ***************" 
                echo "An existing PARFLOW version directory has been found."
                echo "Running this script will completely erase your existing PARFLOW version directory."
                echo "Do you want to proceed? 'y' or 'n'"
                read -n 1 continue
                if [ "$continue" == "n" ]; then
                        exit 0
                else
                        rm -rf $PARFLOW_BASE_DIR/$PARFLOW_VERSION 
                        echo "Existing PARFLOW version directory was removed."
                fi
        fi
else
	echo "Creating New ParFlow Base Directory."
	mkdir -p $PARFLOW_BASE_DIR
fi 

echo "Creating New Version Directory."
mkdir $PARFLOW_BASE_DIR/$PARFLOW_VERSION
export PARFLOW_BUILD_DIR=$PARFLOW_BASE_DIR/$PARFLOW_VERSION
export Source_Dir=$PARFLOW_BUILD_DIR/src

_Get_Code() {
	#################################################################
	#Download the files needed to install the program
	#################################################################

	if [ ! -f $Source_Dir ]; then 
	   mkdir -p $Source_Dir
        fi
	cd $Source_Dir

	if [ ! -f $Source_Dir/silo-4.9.1.tar.gz ]; then 
	  curl "https://wci.llnl.gov/codes/silo/silo-4.9.1/silo-4.9.1.tar.gz" -o "silo-4.9.1.tar.gz"
	fi 

	if [ ! -f $Source_Dir/hypre-2.10.1.tar.gz ]; then 
	  curl "https://computation.llnl.gov/project/linear_solvers/download/hypre-2.10.1.tar.gz" -o "hypre-2.10.1.tar.gz"
	fi 

	if [ ! -f $Source_Dir/parflow-3.3.1.tar.gz ]; then 
	  curl "https://github.com/parflow/parflow/archive/v3.3.1.tar.gz" -o "parflow-3.3.1.tar.gz"
	fi 
}

_Build_Libs() {
	################################################################
	#Create directory structure and untar the tarballs
	################################################################
	###set some env variables
	module load GCC/4.8.3 OpenMPI/1.8.2-GCC-4.8.3
	CC=gcc
	CXX=g++
	FC=gfortran

	 if [ -d $PARFLOW_BUILD_DIR/PARFLOW_LIBS ]; then
            rm -rf  $PARFLOW_BUILD_DIR/PARFLOW_LIBS
            echo "An existing PARFLOW_LIBS directory was removed."
        fi
	mkdir $PARFLOW_BUILD_DIR/PARFLOW_LIBS
	export PARFLOW_LIBS=$PARFLOW_BUILD_DIR/PARFLOW_LIBS
	echo "PARFLOW_LIBS directory was created."

	### creates dir silo-x.x.x###
	cd  $PARFLOW_BUILD_DIR	

	if [ -d $PARFLOW_BUILD_DIR/silo-4.9.1 ]; then
	rm -rf $PARFLOW_BUILD_DIR/silo-4.9.1
	fi 

	echo "Building silo"
	tar -xvf $Source_Dir/silo-4.9.1.tar.gz &> /dev/null 
	cd silo-4.9.1

	./configure --prefix=$PARFLOW_LIBS/silo-4.9.1 --disable-silex &> $PARFLOW_LIBS/Silo_Build_log 
	make -j8 &>  $PARFLOW_LIBS/Silo_Build_log 
	if [ $? -ne 0 ]; then
                echo "Compile Failed!"
                exit 1
        fi
	make install &> /dev/null
	wait ${!}
	rm -rf  $PARFLOW_BUILD_DIR/silo-4.9.1

	### creates dir hypre-x.x.x###
	cd  $PARFLOW_BUILD_DIR

        if [ -d $PARFLOW_BUILD_DIR/hypre-2.10.1 ]; then
        	rm -rf $PARFLOW_BUILD_DIR/hypre-2.10.1
        fi
	
	echo "Building hypre"
	tar -xvf  $Source_Dir/hypre-2.10.1.tar.gz &> /dev/null
	cd hypre-2.10.1/src/
	CC=mpicc
	CXX=mpiCC
	F77=mpif77
	
	./configure --prefix=$PARFLOW_LIBS/hypre-2.10.1 --with-MPI  &>  $PARFLOW_LIBS/hypre_Build_log

	make -j8 &>  $PARFLOW_BUILD_DIR/PARFLOW_LIBS/hypre_Build_log 
	if [ $? -ne 0 ]; then
                echo "Compile Failed!"
                exit 1
        fi
	make install &> /dev/null
	wait ${!}
        rm -rf  $PARFLOW_BUILD_DIR/hypre-2.10.1
}

_Compile() {

	###compile for parflow pfsimulator###
	CC=gcc
	CXX=g++
	FC=gfortran
	TCLPATH=`which tclsh | sed "s,/bin/tclsh,,"`

	if [ -d $PARFLOW_BUILD_DIR/parflow-3.3.1 ]; then
             rm -rf $PARFLOW_BUILD_DIR/parflow-3.3.1
        fi

	echo "Building parflow pfsimulator"
	cd $PARFLOW_BUILD_DIR

	tar -xvf  $Source_Dir/parflow-3.3.1.tar.gz &> /dev/null
	cd $PARFLOW_BUILD_DIR/parflow-3.3.1/pfsimulator

	./configure --prefix=$PARFLOW_BUILD_DIR --enable-timing --with-amps=mpi1 --with-MPICC=mpicc --with-clm --with-amps-sequential-io  --with-hypre=$PARFLOW_LIBS/hypre-2.10.1 --with-silo=$PARFLOW_LIBS/silo-4.9.1 &> $PARFLOW_LIBS/pfsimulator_Build_log

	make -j8 &>  $PARFLOW_LIBS/pfsimulator_Build_log
	if [ $? -ne 0 ]; then
                echo "Compile Failed!"
                exit 1
        fi
	make install &> /dev/null

	###compile for pftools   NOTE pftools are not parallel mpi###
	echo "Building parflow pftools"
	# module unload OpenMPI/1.8.2-GCC-4.8.3
	cd $PARFLOW_BUILD_DIR/ParFlow.r743/pftools

	./configure --prefix=$PARFLOW_BUILD_DIR --enable-timing --with-amps=mpi1 --with-clm --with-amps-sequential-io --with-tcl=$TCLPATH --with-hypre=$PARFLOW_LIBS/hypre-2.10.1 --with-silo=$PARFLOW_LIBS/silo-4.9.1 &> $PARFLOW_LIBS/pftools_Build_log

	make -j8 &>  $PARFLOW_LIBS/pftools_Build_log
	if [ $? -ne 0 ]; then
                echo "Compile Failed!"
                exit 1
        fi
	make install &> /dev/null
	wait ${!}
        rm -rf $PARFLOW_BUILD_DIR/src
}

_Test(){
	###test if the install is correct###
        module load GCC/4.8.3 OpenMPI/1.8.2-GCC-4.8.3
        export PARFLOW_DIR=$PARFLOW_BUILD_DIR
	cd $PARFLOW_DIR/ParFlow.r743/test

	echo "test will be put in a file named: Parflow_install_test_log"
	echo "run:  tail -f $PARFLOW_DIR/ParFlow.r743/test/Parflow_install_test_log   to watch test"

	make check &> Parflow_install_test_log
}

##########Run all functions##########
echo "***** Unpacking Code *****"
_Get_Code
wait ${!} 

echo "***** Building Libraries *****"
_Build_Libs
wait ${!}

echo "***** Starting Compile *****"
_Compile
wait ${!}

# echo "***** Starting test of Installation*****"
# _Test
# wait ${!}

echo "***** Parflow setup complete! *****"


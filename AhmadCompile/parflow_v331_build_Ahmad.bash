#!/bin/bash

#
# ./ParFlow_Build.bash
#

##############################################################
# R2 specific stuff 
###############################################################
# module rm silo/4.10.2 hypre/2.11.2 openblas/dynamic/0.2.20 m4/1.4.17 
# module rm automake/1.15 autoconf/2.69 cmake/gcc/3.12.4 gcc/7.2.0 hdf5/gcc/1.10.5 
###
CMAKE_VERSION=3.14.5
SILO_VERSION=4.9.1
HYPRE_VERSION=2.11.2
DOWNLOAD_DIR=~/download_app
GCC_MODULE=GCC/4.9.3
OPENMPI_MODULE=OpenMPI/1.8.7-GCC-4.9.3
NUM_BUILD_CORES=8
CC=gcc
CXX=g++
DOWNLOAD=true
COMPILE_LIBS=true

export PARFLOW_BASE_DIR=~/parflow
export PARFLOW_VERSION=3.3.1
export PARFLOW_DIR=${PARFLOW_BASE_DIR}/${PARFLOW_VERSION}
export PARFLOW_SCRIPT_DIR=$(dirname $(readlink -f $0))   # get location of where script was run from.  /cm/shared/scripts...
export PARFLOW_BUILD_DIR=$PARFLOW_DIR/build
export SOURCE_DIR=$PARFLOW_DIR/src
export PARFLOW_LIBS=$PARFLOW_BASE_DIR/PARFLOW_LIBS
export PARFLOW_INSTALL_DIR=$PARFLOW_DIR/install

#################################################################
# check for current version install
#################################################################
if [ -d $PARFLOW_BASE_DIR ]; then
        echo "An existing Parflow Base Directory found, Parflow will build under this."

        if [ -d $PARFLOW_DIR ]; then
                echo "***************  WARNING  ***************" 
                echo "An existing PARFLOW version directory has been found."
                echo "Running this script will completely erase your existing PARFLOW version directory."
                echo "Do you want to proceed? 'y' or 'n'"
                read -n 1 continue
                if [ "$continue" == "n" ]; then
                        exit 0
                else
                        rm -rf $PARFLOW_DIR 
                        echo "Existing PARFLOW version directory was removed."
                fi
        fi
else
	echo "Creating New ParFlow Base Directory."
	mkdir -p $PARFLOW_BASE_DIR
fi 

echo "Creating New Version Directory."
mkdir $PARFLOW_DIR
mkdir $PARFLOW_BUILD_DIR
mkdir $PARFLOW_INSTALL_DIR

_Download_Sources(){
	#################################################################
	#Download the files needed to install the program
	#################################################################
	if [ ! -f $DOWNLOAD_DIR ]; then 
	   mkdir -p $DOWNLOAD_DIR
        fi
	cd $DOWNLOAD_DIR
	
	if [ ! -f $DOWNLOAD_DIR/cmake-${CMAKE_VERSION}.tar.gz ]; then
     echo "***** Begin download cmake-${CMAKE_VERSION}"	
	 curl -L "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz" -o "${DOWNLOAD_DIR}/cmake-${CMAKE_VERSION}.tar.gz"	
	fi	

	if [ ! -f $DOWNLOAD_DIR/silo-${SILO_VERSION}.tar.gz ]; then
	 echo "***** Begin download silo-${SILO_VERSION}"	 	
	 curl -L "https://wci.llnl.gov/codes/silo/silo-${SILO_VERSION}/silo-${SILO_VERSION}.tar.gz" -o "${DOWNLOAD_DIR}/silo-${SILO_VERSION}.tar.gz"	
	fi 
	
	if [ ! -f $DOWNLOAD_DIR/hypre-${HYPRE_VERSION}.tar.gz ]; then 
      echo "***** Begin download hypre-${HYPRE_VERSION}"	
	  curl -L "https://computation.llnl.gov/project/linear_solvers/download/hypre-${HYPRE_VERSION}.tar.gz" -o "${DOWNLOAD_DIR}/hypre-${HYPRE_VERSION}.tar.gz"	  
	fi 

	if [ ! -f $DOWNLOAD_DIR/parflow-${PARFLOW_VERSION}.tar.gz ]; then 
      echo "***** Begin download parflow-${PARFLOW_VERSION}"	
	  curl -L "https://github.com/parflow/parflow/archive/v${PARFLOW_VERSION}.tar.gz" -o "parflow-${PARFLOW_VERSION}.tar.gz"
	fi 
	
}


_Get_Code() {
	#################################################################
	#Copy the files needed to install the program
	#################################################################

	if [ ! -f $SOURCE_DIR ]; then 
	   mkdir -p $SOURCE_DIR
        fi
	cd $SOURCE_DIR
	
	if [ ! -f $SOURCE_DIR/cmake-${CMAKE_VERSION}.tar.gz ]; then	 
	 cp ${DOWNLOAD_DIR}/cmake-${CMAKE_VERSION}.tar.gz $SOURCE_DIR 
	fi
	

	if [ ! -f $SOURCE_DIR/silo-${SILO_VERSION}.tar.gz ]; then 		 
	 cp ${DOWNLOAD_DIR}/silo-${SILO_VERSION}.tar.gz $SOURCE_DIR 
	fi 
	
	if [ ! -f $SOURCE_DIR/hypre-${HYPRE_VERSION}.tar.gz ]; then 	 
	  cp ${DOWNLOAD_DIR}/hypre-${HYPRE_VERSION}.tar.gz $SOURCE_DIR 
	fi 

	if [ ! -f $SOURCE_DIR/parflow-${PARFLOW_VERSION}.tar.gz ]; then 
    	cp ${DOWNLOAD_DIR}/parflow-${PARFLOW_VERSION}.tar.gz $SOURCE_DIR	 
	fi 
}

_Build_Libs() {
	################################################################
	#Create directory structure and untar the tarballs
	################################################################
	###set some env variables
	
	module load ${GCC_MODULE} 
	module load ${OPENMPI_MODULE}
	CC=gcc
	CXX=g++
	FC=gfortran

	 if [ ! -d $PARFLOW_BASE_DIR/PARFLOW_LIBS ]; then
            #rm -rf  $PARFLOW_BASE_DIR/PARFLOW_LIBS
			mkdir $PARFLOW_BASE_DIR/PARFLOW_LIBS
            echo "Added PARFLOW_LIBS directory."
     fi
	
	
	#echo "PARFLOW_LIBS directory was created."

	### creates dir cmake-x.x.x###
	cd  $PARFLOW_BUILD_DIR	

	if [ -d $PARFLOW_BUILD_DIR/cmake-${CMAKE_VERSION} ]; then
	rm -rf $PARFLOW_BUILD_DIR/cmake-${CMAKE_VERSION}
	fi 

	echo "Building cmake"
	tar -xvf $SOURCE_DIR/cmake-${CMAKE_VERSION}.tar.gz &> /dev/null 
	cd cmake-${CMAKE_VERSION}

	./bootstrap --prefix=$PARFLOW_LIBS/cmake-${CMAKE_VERSION} &> $PARFLOW_LIBS/cmake_build.log 
	make -j${NUM_BUILD_CORES} &>  $PARFLOW_LIBS/cmake_build.log 
	if [ $? -ne 0 ]; then
                echo "Compile Failed!"
                exit 1
        fi
	make install &> /dev/null
	wait ${!}
	rm -rf  $PARFLOW_BUILD_DIR/cmake-${CMAKE_VERSION}


	### creates dir silo-x.x.x###
	cd  $PARFLOW_BUILD_DIR	

	if [ -d $PARFLOW_BUILD_DIR/silo-${SILO_VERSION} ]; then
	rm -rf $PARFLOW_BUILD_DIR/silo-${SILO_VERSION}
	fi 

	echo "Building silo"
	tar -xvf $SOURCE_DIR/silo-${SILO_VERSION}.tar.gz &> /dev/null 
	cd silo-${SILO_VERSION}

	./configure --prefix=$PARFLOW_LIBS/silo-${SILO_VERSION} --disable-silex &> $PARFLOW_LIBS/silo_config.log 
	make -j${NUM_BUILD_CORES} &>  $PARFLOW_LIBS/silo_build.log 
	if [ $? -ne 0 ]; then
                echo "Compile Failed!"
                exit 1
        fi
	make install &> /dev/null
	wait ${!}
	rm -rf  $PARFLOW_BUILD_DIR/silo-${SILO_VERSION}

	### creates dir hypre-x.x.x###
	cd  $PARFLOW_BUILD_DIR

        if [ -d $PARFLOW_BUILD_DIR/hypre-${HYPRE_VERSION} ]; then
        	rm -rf $PARFLOW_BUILD_DIR/hypre-${HYPRE_VERSION}
        fi
	
	echo "Building hypre"
	tar -xvf  $SOURCE_DIR/hypre-${HYPRE_VERSION}.tar.gz &> /dev/null
	cd hypre-${HYPRE_VERSION}/src/
	CC=mpicc
	CXX=mpiCC
	F77=mpif77
	
	./configure --prefix=$PARFLOW_LIBS/hypre-${HYPRE_VERSION} --with-MPI  &>  $PARFLOW_LIBS/hypre_config.log

	make -j${NUM_BUILD_CORES} &>  $PARFLOW_LIBS/hypre_build.log 
	if [ $? -ne 0 ]; then
                echo "Compile Failed!"
                exit 1
        fi
	make install &> /dev/null
	wait ${!}
    rm -rf  $PARFLOW_BUILD_DIR/hypre-${HYPRE_VERSION}
}

_Compile() {

	###compile for parflow pfsimulator###
	CC=gcc
	CXX=g++
	FC=gfortran
	TCLPATH=`which tclsh | sed "s,/bin/tclsh,,"`

	if [ -d $PARFLOW_BUILD_DIR/parflow-${PARFLOW_VERSION} ]; then
         rm -rf $PARFLOW_BUILD_DIR/parflow-${PARFLOW_VERSION}
    fi

	echo "Building parflow"
	cd $PARFLOW_BUILD_DIR
	
	module load ${OPENMPI_MODULE}
	
	tar -xvf  $SOURCE_DIR/parflow-${PARFLOW_VERSION}.tar.gz -C $PARFLOW_DIR &> /dev/null
	#cd $PARFLOW_BUILD_DIR/parflow-${PARFLOW_VERSION}/pfsimulator
	#echo "this is where1"
	#./configure --prefix=$PARFLOW_BUILD_DIR --enable-timing --with-amps=mpi1 --with-MPICC=mpicc --with-clm --with-amps-sequential-io  --with-hypre=$PARFLOW_LIBS/hypre-${HYPRE_VERSION} --with-silo=$PARFLOW_LIBS/silo-${SILO_VERSION} &> $PARFLOW_LIBS/pfsimulator_config.log
	cd $PARFLOW_BUILD_DIR 

	$PARFLOW_LIBS/cmake-${CMAKE_VERSION}/bin/cmake ../parflow-${PARFLOW_VERSION} -DCMAKE_INSTALL_PREFIX=$PARFLOW_INSTALL_DIR -DPARFLOW_AMPS_LAYER=mpi1 -DPARFLOW_ENABLE_TIMING=true -DPARFLOW_HAVE_CLM=ON -DTK_INCLUDE_PATH=${TCLPATH} -DHYPRE_ROOT=${PARFLOW_LIBS}/hypre-${HYPRE_VERSION} -DSILO_ROOT=${PARFLOW_LIBS}/silo-${SILO_VERSION} -DPARFLOW_AMPS_SEQUENTIAL_IO=TRUE &> ${PARFLOW_LIBS}/parflow_cmake.log
	
	#echo "this is where2"
	make -j${NUM_BUILD_CORES} &>  $PARFLOW_LIBS/parflow_build.log
	if [ $? -ne 0 ]; then
                echo "Compile Failed!"
                exit 1
        fi
	make install &> $PARFLOW_LIBS/parflow_install.log

	###compile for pftools   NOTE pftools are not parallel mpi###
	echo "Building parflow pftools"
	# module unload ${OPENMPI_MODULE}
	# cd $PARFLOW_BUILD_DIR/ParFlow.r743/pftools

	# ./configure --prefix=$PARFLOW_BUILD_DIR --enable-timing --with-amps=mpi1 --with-clm --with-amps-sequential-io --with-tcl=$TCLPATH --with-hypre=$PARFLOW_LIBS/hypre-${HYPRE_VERSION} --with-silo=$PARFLOW_LIBS/silo-${SILO_VERSION} &> $PARFLOW_LIBS/pftools_config.log

	# make -j${NUM_BUILD_CORES} &>  $PARFLOW_LIBS/pftools_build.log
	# if [ $? -ne 0 ]; then
                # echo "Compile Failed!"
                # exit 1
        # fi
	# make install &> /dev/null
	
	wait ${!}
    rm -rf $PARFLOW_DIR/src
}

_Test(){
	###test if the install is correct###
       # module load ${GCC_MODULE}
        module load	${OPENMPI_MODULE} 
        export PARFLOW_DIR=$PARFLOW_BUILD_DIR
	cd $PARFLOW_DIR/ParFlow.r743/test

	echo "test will be put in a file named: parflow_install_test.log"
	echo "run:  tail -f $PARFLOW_DIR/ParFlow.r743/test/parflow_install_test.log   to watch test"

	make check &> parflow_install_test.log
}

##########Run all functions##########
if [ $DOWNLOAD = true ]; then
	echo "***** Downloading Sources *****"
	_Download_Sources
	wait ${!}
fi

echo "***** Unpacking Code *****"
_Get_Code
wait ${!} 

if [ $COMPILE_LIBS = true ]; then
	echo "***** Building Libraries *****"
	_Build_Libs
	wait ${!}
fi

echo "***** Starting Compile *****"
_Compile
wait ${!}

# echo "***** Starting test of Installation*****"
# _Test
# wait ${!}

echo "***** Parflow setup complete! *****"


#!/bin/bash
#PBS -q mpi_7
#PBS -l select=7:ncpus=28:mpiprocs=29:mem=65G
#PBS -l walltime=02:00:00
#PBS -N N420OFFTRC
#PBS -eo 


cd $PBS_O_WORKDIR
qstat -f $PBS_JOBID
ls $TMPDIR
echo $SCRATCH
echo $DATAWORK
echo $HOST
pbsnodes $HOST
source /usr/share/Modules/3.2.10/init/bash
module load DCM/4.2.0

module list
which wo
pwd 

set -x
ulimit -s 
ulimit -s unlimited

CONFIG=CREG025.L75
CASE=N420OFFTRC

CONFCASE=${CONFIG}-${CASE}
CTL_DIR=$HOME/RUNS/RUN_${CONFIG}/${CONFCASE}/CTL

# Following numbers must be consistant with the header of this job
export NB_NPROC=195   # number of cores used for NEMO
export NB_NPROC_IOS=7  # number of cores used for xios (number of xios_server.exe)
export NB_NCORE_DP=0    # activate depopulated core computation for XIOS. If not 0, RUN_DP is
                        # the number of cores used by XIOS on each exclusive node.
# Rebuild process 
export MERGE=0          # 0 = on the fly rebuild, 1 = dedicated job
export NB_NPROC_MER=28 # number of cores used for rebuild on the fly  (1/node is a good choice)
export NB_NNODE_MER=1  # number of nodes used for rebuild in dedicated job (MERGE=0). One instance of rebuild per node will be used.
export WALL_CLK_MER=3:00:00   # wall clock time for batch rebuild

date
#
echo " Read corresponding include file on the HOMEWORK "
.  ${CTL_DIR}/includefile.sh

. $RUNTOOLS/lib/function_4_all.sh
. $RUNTOOLS/lib/function_4.sh
#  you can eventually include function redefinitions here (for testing purpose, for instance).
##	runcode_mpmd() {
##	echo 'yes, this was created in functions_3.2_datarmor'
##	
##	n1=$1
##	n2=$3
##	prog1=$2
##	prog2=$4
##	
##	
##	# get the path for mpirun
##	source /usr/share/Modules/3.2.10/init/bash
##	 module purge
##	 module load   NETCDF/4.3.3.1-mpt-intel2016  # faster (9:03.32)  but result not exact  as caparmor 
##	# module load   NETCDF-test/4.3.3.1-mpt217-intel2018 
##	 module load   nco/4.6.4_gcc-6.3.0
##	 module list
##	export mpiproc=`cat $PBS_NODEFILE  |wc -l`
##	
##	echo "submit job with  $NETCDF_MODULE "
##	echo "job running with  $mpiproc mpi process  here you should see 30 * 28"
##	date
##	
##	date
##	time $MPI_LAUNCH -n 28 ${prog1} : -n 1 ${prog2} :    \
##	                 -n 28 ${prog1} : -n 1 ${prog2} >& output.mpi
##	date
##	               }
# ---

. $RUNTOOLS/lib/nemo4.sh

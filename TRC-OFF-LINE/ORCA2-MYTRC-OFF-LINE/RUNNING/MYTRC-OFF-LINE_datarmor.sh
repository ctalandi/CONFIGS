#!/bin/bash
#PBS -q mpi_2
#PBS -l select=2:ncpus=28:mpiprocs=29:mem=65G
#PBS -l walltime=01:00:00
#PBS -N RUN-MYTRC
#PBS -eo 


cd $PBS_O_WORKDIR
qstat -f $PBS_JOBID
pbsnodes $HOST
source /usr/share/Modules/3.2.10/init/bash
module load DCM/4.2.0

module list
which wo
pwd 

set -x
ulimit -s 
ulimit -s unlimited

# function for running OPA ans XIOS : it takes the number of procs and name of programs as argument
#    runcode_mpmd  nproc1 prog1    nproc2 prog2   ... nprocn progn
runcode_mpmd() {
echo 'yes, this was created in functions_3.2_datarmor'

n1=$1
n2=$3
prog1=$2
prog2=$4


# get the path for mpirun
source /usr/share/Modules/3.2.10/init/bash
 module purge
 module load   NETCDF-test/4.3.3.1-mpt217-intel2018
 module list
export mpiproc=`cat $PBS_NODEFILE  |wc -l`

echo "submit job with  $NETCDF_MODULE "
echo "job running with  $mpiproc mpi process  here you should see 30 * 28"
date

date
###                     time $MPI_LAUNCH -n 28 ${prog1} : \
###                                      -n 28 ${prog1}  >& output.mpi
######  time $MPI_LAUNCH -n 28 ${prog1} : -n 1 ${prog2} :    \
######                   -n 28 ${prog1} : -n 1 ${prog2} >& output.mpi
time $MPI_LAUNCH -n 28 ${prog1} : -n 1 ${prog2} :    \
                 -n 28 ${prog1} : -n 1 ${prog2} >& output.mpi
date
               }
# ---



cd /home1/scratch/ctalandi/MYCONFIG

ln -sf /home1/datahome/ctalandi/DEV/NEMO/nemo_4.2.0/cfgs/MYCONFIG/BLD/bin/nemo.exe nemo4.exe
ln -sf /home1/datahome/ctalandi/DEV/XIOS/xios-trunk_r2320/bin/xios_server.exe .

cp /home1/datahome/ctalandi/DEV/NEMO/nemo_4.2.0/cfgs/MYCONFIG/EXP00/* .

ln -sf /home1/datawork/ctalandi/RUN-ORCA2-OFF-TRC/ORCA2_OFF_v4.2.0_LITE/ORCA_R2_zps_domcfg.nc .
ln -sf /home1/datawork/ctalandi/RUN-ORCA2-OFF-TRC/ORCA2_OFF_v4.2.0_LITE/dyna_grid*.nc .


runcode_mpmd  56 ./nemo4.exe 2 ./xios_server.exe




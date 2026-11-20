#!/bin/bash
#SBATCH --job-name=NEMO423PIS
#SBATCH --partition=cpu
#SBATCH --ntasks=192
#SBATCH --mem=700G
#SBATCH --time=24:00:00
#SBATCH --output=./JOBS-OUT/NEMO423PIS.%j.out
#SBATCH --error=./JOBS-OUT/NEMO423PIS.%j.err
#SBATCH --mail-user=ctalandi@ifremer.fr
#SBATCH --mail-type=BEGIN,END,FAIL

#####SBATCH --ntasks=366
####SBATCH --nodelist=compute-116-[9,11,13]

source /usr/share/Modules/init/bash
module load DCM/4.2.3

# To set the proper paths for NETCDF library
source /project/oh/drakkar/LIBRAIRIES/NETCDF/env_netcdf_gnu.sh

cd $SLURM_SUBMIT_DIR
ls $TMPDIR
echo $SCRATCH
echo $WORK
echo $HOST
# Show the nodes list
sinfo -N

module list
which wo
pwd 

#set -x
ulimit -s 
ulimit -s unlimited

CONFIG=CREG025.L75
CASE=NEMO423PIS
CONFCASE=${CONFIG}-${CASE}
CTL_DIR=$HOME/RUNS/RUN_${CONFIG}/${CONFCASE}/CTL

# Following numbers must be consistant with the header of this job
export NB_NPROC=190     # number of cores used for NEMO
export NB_NPROC_IOS=2  # number of cores used for xios (number of xios_server.exe)
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

# To get specific files that are not managed by DCM
cd ${TMPDIR}
. ${CTL_DIR}/get_inputfilesHand.bash
cd ${CTL_DIR}

. $RUNTOOLS/lib/function_4_all.sh
. $RUNTOOLS/lib/function_4.sh
#  you can eventually include function redefinitions here (for testing purpose, for instance).

runcode_mpmd() {

echo '	Function runcode_mpmd has been overwritten in CREG025.L75-NEMO423PIS_datarmor.sh '

n_nemo=$1
prog1=$2
n_xios=$3
prog2=$4

# get the path for mpirun
echo "submit job with  $NETCDF_MODULE "
date

date
time mpirun -n ${n_nemo} ${prog1} : -n ${n_xios} ${prog2} >& output.mpi
#time srun -n ${n_nemo} ${prog1} : -n ${n_xios} ${prog2} >& output.mpi
date
               }
# ---
. $RUNTOOLS/lib/nemo4.sh

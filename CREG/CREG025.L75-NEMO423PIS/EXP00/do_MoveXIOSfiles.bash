#!/bin/bash
#set -xv

module load DCM/4.2.3

# This script has to be located into a CREG025.L75-CASE/CTL directory structure

# Get the experiment name 
CASE=`pwd | awk -F / '{print $6}' | awk -F - '{print $2}'`

# Give as argument the first and last stream to treat (usually 1 stream corresponds to a single year)
is=$1
ie=$2

for id in `seq ${is} ${ie} `; do cd ${SCRATCH}/CREG025.L75-${CASE}-XIOS.${id} ; dcmtk_mvnc2s ; cd ../ ; done


# Save also ANNEX directory which contains all NEMO riunning usfull files such as namelist, ocean.output etc ...
echo 
echo " --> Save NEMO running file from ANNEX"
echo 
for exp in `echo  ${CASE} `; do
	DATAIN=/scratch/ctalandi/CREG025.L75/CREG025.L75-${CASE}-S
	DATAOU=/scale/project/drakkarcom/SIMULATION-OUTPUTS/FREDY/CONFIGS/CREG025.L75/CREG025.L75-${CASE}-MEAN/
	rsync -tr ${DATAIN}/ANNEX  ${DATAOU}/. ;
	cd ../ ;
done


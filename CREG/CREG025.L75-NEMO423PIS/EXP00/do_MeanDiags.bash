#!/bin/bash

#set -xv

# This script has to be located into a CREG025.L75-CASE/CTL directory structure

# Get the experiment name 
CASE=`pwd | awk -F / '{print $6}' | awk -F - '{print $2}'`


# Give as argument the first and last year to treat
ys=$1
ye=$2

# Compute the ice/oce stress 
##################################################################
cd /work/ctalandi/PRE-POST/CURL
for freq in `echo 1m 5d`; do 
	sed -e "s/<XXSYEARXX>/$ys/"  \
	    -e "s/<XXEYEARXX>/$ye/"  \
	    -e "s/<XXFREQXX>/$freq/"  \
	    -e "s/<XXCASEXX>/$CASE/"  make_curl.slurm.tmp > make_curl_y${ys}-${ye}.${freq}.slurm
	sbatch make_curl_y${ys}-${ye}.${freq}.slurm
	
	echo
	echo "	---> Job for the curl make_curl_y${ys}-${ye}.${freq}.slurm launched "
	echo
done 

exit

# Compute the mean fields
##################################################################
cd /home/ctalandi/RUNS/RUN_CREG025.L75/CREG025.L75-${CASE}/CTL/CDF
if [ ! -d JOBS-OUT ] ; then mkdir JOBS-OUT ; fi 

. ./config_moy.ksh 
. ./function_moy.ksh 

# The following mean process is expecting time splitted input files, i.e.
# in case of monthly output files: 12 monthly mean 
# in case of 5days output files  : 5 5d output for each month 
for year in `seq $ys $ye `; do 
	cat Mean1y.slurm.tmp | sed -e "s/<CONFIG>/$CONFIG/" -e "s/<CASE>/$CASE/" \
	     -e "s/<year>/$year/g" -e "s@<JBNAME>@Ym${year}@" > ./JOBS-OUT/zcalannual_$year.slurm
	
	submit ./JOBS-OUT/zcalannual_$year.slurm

	echo
	echo "	---> Job for the annual mean zcalannual_$year.slurm launched "
	echo

done


# for id in `seq ${ys} ${ye} `; do ./RUN_calmoy.ksh $id ; done

#!/bin/bash

set -xv

# This script has to be located into a CREG025.L75-CASE/CTL directory structure

# Get the experiment name 
case=`pwd | awk -F / '{print $6}' | awk -F - '{print $2}'`


# Give as argument the first and last year to treat
ys=$1
ye=$2

# Compute the ice/oce stress 
cd /work/ctalandi/PRE-POST/CURL
sed -e "s/<XXSYEARXX>/$ys/"  \
    -e "s/<XXEYEARXX>/$ye/"  \
    -e "s/<XXCASEXX>/$case/"  make_curl.slurm.tmp > make_curl.slurm
sbatch make_curl.slurm


# Compute the mean fields
cd /home/ctalandi/RUNS/RUN_CREG025.L75/CREG025.L75-${case}/CTL/CDF
if [ ! -d JOBS-OUT ] ; then mkdir JOBS-OUT ; fi 
for id in `seq ${ys} ${ye} `; do ./RUN_calmoy.ksh $id ; done





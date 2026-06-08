#!/bin/bash

set -xv 

s_year=$1 
e_year=$2

for year in `seq -w ${s_year} ${e_year} `; do 

	sed -e "s/XXYEARXX/$year/"  FREEBIORYS_from_ORCA_to_CREG_grid.bash > ./JOBS/FREEBIORYS_from_ORCA_to_CREG_grid_y${year}.pbs
	cd ./JOBS 
	qsub FREEBIORYS_from_ORCA_to_CREG_grid_y${year}.pbs
	cd ../

done 

#!/bin/bash
#PBS -l mem=8g
#PBS -l walltime=03:30:00
#PBS -N FBXXYEARXX
#PBS -eo 
set -xv 

cd $PBS_O_WORKDIR
cd ../

source /usr/share/Modules/3.2.10/init/bash
module load nco/4.6.4_gcc-6.3.0
module load NETCDF-test/4.3.3.1-mpt217-intel2018

year=XXYEARXX
OUDIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/MERCATOR/FREEBIORYS2V4/INIT/CREG025.L75
monthly=1
yearly=0

if [ ! -d ./CREG025.L75-FREEBIORYS2V4/${year} ]   ; then
	mkdir -p ./CREG025.L75-FREEBIORYS2V4/${year}
fi

if [ ! -d ${OUDIR}/${year} ]   ; then
	mkdir -p ${OUDIR}/${year}
fi


cd ./CREG025.L75-FREEBIORYS2V4/${year}

ln -sf /home1/datahome/ctalandi/DEV/FREDY/CONFIGS/CREG025.L75/ORCA-CREG-GRID/bin/convert_wrap_orca025_BioT .

date 
 
for var in `echo alk bfe caco3 chl dchl dfe dic doc dsi fe goc gsi nchl nfe nh4 no3 nppv o2 par phy2 phyc phy po4 poc sfe si zoo2 zoo ` ; do 

# FOR MONTHLY DATA (GLOBAL ORCA GRID)
#####################################
if [ $monthly -eq 1 ] ; then 
	INDIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/MERCATOR/FREEBIORYS2V4/INIT/ORCA025
	echo 
	echo " The variable treated is : $var " 
	echo 
	# Monthly files
	month=1
	while [ $month -le 12 ]  ; do
		if [ $month -le 9 ] ; then
		    zmonth="0${month}"
		else
		    zmonth=${month}
		fi
	        file_i=FREEBIORYS2V4_ORCA025_1m_y${year}m${zmonth}_${var}.nc
                file_o=FREEBIORYS2V4-CREG025.L75_${var}_1m_y${year}m${zmonth}.nc
	
		ln -sf ${INDIR}/${year}/${file_i} .
	
		./convert_wrap_orca025_BioT  ${file_i} ${file_o} ${var}
	
		let month=$month+1
	
	done 

        ncrcat -n 12,2,1 FREEBIORYS2V4-CREG025.L75_${var}_1m_y${year}m01.nc FREEBIORYS2V4-CREG025.L75_${var}_1m_y${year}.nc
	mv FREEBIORYS2V4-CREG025.L75_${var}_1m_y${year}.nc  ${OUDIR}/${year}/.

fi


# FOR YEARLY DATA (A FRACTION OF ORCA GRID)
###########################################
if [ $yearly -eq 1 ] ; then 
	INDIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/MERCATOR/FREEBIORYS2V4/INIT/FOLD-CREG025
	echo 
	echo " The variable treated is : $var " 
	echo 
	file_i=FREEBIORYS2V4_FOLD-CREG025_1m_y${year}_${var}.nc
        file_o=FREEBIORYS2V4-CREG025.L75_${var}_1m_y${year}.nc
	
	ln -sf ${INDIR}/${year}/${file_i} .
	
	./convert_wrap_orca025_BioT  ${file_i} ${file_o} ${var}

	#mv FREEBIORYS2V4-CREG025.L75_${var}_1m_y${year}.nc  ${OUDIR}/${year}/.

fi

done 

date


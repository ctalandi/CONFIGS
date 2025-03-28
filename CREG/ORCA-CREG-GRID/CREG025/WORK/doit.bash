#/bin/bash

set -xv 

year=1988

if [ ! -d ./CREG025.L75-GJM189-MEAN/${year}/5d ]   ; then
	mkdir -p ./CREG025.L75-GJM189-MEAN/${year}/5d/
fi

# Monthly files
month=1
while [ $month -le 12 ]  ; do
	if [ $month -le 9 ] ; then
	    zmonth="0${month}"
	else
	    zmonth=${month}
	fi
	fileT=ORCA025.L75-GJM189_y${year}m${zmonth}_gridT.nc
	fileV=ORCA025.L75-GJM189_y${year}m${zmonth}_gridV.nc
	fileoutT=CREG025.L75-GJM189_y${year}m${zmonth}_gridT.nc
	fileoutV=CREG025.L75-GJM189_y${year}m${zmonth}_gridV.nc

	ln -sf /net/krypton/data0/project/drakkar/CONFIGS/ORCA025.L75/ORCA025.L75-GJM189-MEAN/${year}/${fileT} .
	ln -sf /net/krypton/data0/project/drakkar/CONFIGS/ORCA025.L75/ORCA025.L75-GJM189-MEAN/${year}/${fileV} .

	./convert_wrap_orca025_gridV ${fileV} ${fileoutV}
	./convert_wrap_orca025_gridT ${fileT} ${fileoutT}

	mv ${fileoutV} ./CREG025.L75-GJM189-MEAN/${year}/5d/
	mv ${fileoutT} ./CREG025.L75-GJM189-MEAN/${year}/5d/

	let month=$month+1

done 

# Yearly files
fileT=ORCA025.L75-GJM189_y${year}_gridT.nc
fileV=ORCA025.L75-GJM189_y${year}_gridV.nc
fileoutT=CREG025.L75-GJM189_y${year}_gridT.nc
fileoutV=CREG025.L75-GJM189_y${year}_gridV.nc

ln -sf /net/krypton/data0/project/drakkar/CONFIGS/ORCA025.L75/ORCA025.L75-GJM189-MEAN/${year}/${fileT} .
ln -sf /net/krypton/data0/project/drakkar/CONFIGS/ORCA025.L75/ORCA025.L75-GJM189-MEAN/${year}/${fileV} .

./convert_wrap_orca025_gridV ${fileV} ${fileoutV}
./convert_wrap_orca025_gridT ${fileT} ${fileoutT}

mv ${fileoutV} ./CREG025.L75-GJM189-MEAN/${year}/5d/
mv ${fileoutT} ./CREG025.L75-GJM189-MEAN/${year}/5d/


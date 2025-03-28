#/bin/bash

set -xv 

year=1986

if [ ! -d ./CREG12.L75-MJM189-MEAN/${year}/5d ]   ; then
	mkdir -p ./CREG12.L75-MJM189-MEAN/${year}/5d/
fi

# Monthly files
month=1
while [ $month -le 12 ]  ; do
	if [ $month -le 9 ] ; then
	    zmonth="0${month}"
	else
	    zmonth=${month}
	fi
	fileT=ORCA12.L75-MJM189_y${year}m${zmonth}.5d_gridT.nc
	fileV=ORCA12.L75-MJM189_y${year}m${zmonth}.5d_gridV.nc
	fileoutT=CREG12.L75-MJM189_y${year}m${zmonth}.5d_gridT.nc
	fileoutV=CREG12.L75-MJM189_y${year}m${zmonth}.5d_gridV.nc

	ln -sf /net/krypton/data0/project/drakkar/CONFIGS/ORCA12.L75/ORCA12.L75-MJM189-MEAN/${year}/${fileT} .
	ln -sf /net/krypton/data0/project/drakkar/CONFIGS/ORCA12.L75/ORCA12.L75-MJM189-MEAN/${year}/${fileV} .

	./convert_wrap_orca12_gridV ${fileV} ${fileoutV}
	./convert_wrap_orca12_gridT ${fileT} ${fileoutT}

	mv ${fileoutV} ./CREG12.L75-MJM189-MEAN/${year}/5d/
	mv ${fileoutT} ./CREG12.L75-MJM189-MEAN/${year}/5d/

	let month=$month+1

done 

# Yearly files
fileT=ORCA12.L75-MJM189_y${year}.5d_gridT.nc
fileV=ORCA12.L75-MJM189_y${year}.5d_gridV.nc
fileoutT=CREG12.L75-MJM189_y${year}.5d_gridT.nc
fileoutV=CREG12.L75-MJM189_y${year}.5d_gridV.nc

ln -sf /net/krypton/data0/project/drakkar/CONFIGS/ORCA12.L75/ORCA12.L75-MJM189-MEAN/${year}/${fileT} .
ln -sf /net/krypton/data0/project/drakkar/CONFIGS/ORCA12.L75/ORCA12.L75-MJM189-MEAN/${year}/${fileV} .

./convert_wrap_orca12_gridV ${fileV} ${fileoutV}
./convert_wrap_orca12_gridT ${fileT} ${fileoutT}

mv ${fileoutV} ./CREG12.L75-MJM189-MEAN/${year}/5d/
mv ${fileoutT} ./CREG12.L75-MJM189-MEAN/${year}/5d/


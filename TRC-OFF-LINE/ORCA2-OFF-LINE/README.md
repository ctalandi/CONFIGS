# ORCA2-OFF-LINE configuration
Gather here all required files to be able to run this configuration.

0 - GENERAL INFORMATION:<br>
1 - NEMO CODE:<br>
2 - COMPILATION:<br> 
3 - INPUT FILES:<br>
4 - SUBMISSION: <br>
  
---
## 0 - GENERAL INFORMATION: <br>
Usefull information might be found on the follwing link : https://sites.nemo-ocean.io/user-guide/cfgs.html <br>
Maybe the closest configuration to the passive tracers one: https://sites.nemo-ocean.io/user-guide/cfgs.html#orca2-off-pisces <br>

---
## 1 - NEMO CODE: <br>
The official NEMO release can be donwloaded following instructions on this page: https://forge.nemo-ocean.eu/nemo/nemo/-/releases. <br> 
The GIT command line should look like the following one: <br> 
```
git clone --branch 4.2.0 https://forge.nemo-ocean.eu/nemo/nemo.git nemo_4.2.0
```

---
## 2 - COMPILATION: <br>

All the following has been done on Datarmor. <br>

Load appropriate modules : <br> 
```
module purge 
module load NETCDF-test/4.3.3.1-mpt217-intel2018
```

Save the adapted F90 modules there [./CODE/MY_SRC] into the ./nemo_4.2.0/cfgs/ORCA2_OFF_TRC/MY_SRC directory. <br>
These changes are specific to key_mpi2 that has been used on Datarmor, if the cpp key key_mpi2 is not used, then this setp is useless.<br>

Save the file containing the compilation option there [./CODE/ARCH/arch-X64_DATARMORMPI.fcm] under the ./nemo_4.2.0/arch/CNRS directory. <br>
Note: One more step would be required to donwload and compile the XIOS library which is used to manage outputs; here for simplicity we just use the one already 
compiled and availbale on Datarmor with is the release 2320.

Launch the compilation as below: <br>
```
./makenemo -r ORCA2_OFF_TRC -m X64_DATARMORMPI -j 12  add_key ‘key_mpi2’ 
```

The compilation step result in a binary nemo.exe located there [./nemo_4.2.0/cfgs/ORCA2_OFF_TRC/BLD/bin/nemo.exe]

---
## 3 - INPUT FILES:<br>
Input data for running the ORCA2_OFF_TRC reference configuration in there: https://gws-access.jasmin.ac.uk/public/nemo/sette_inputs/ <br>
The command to download the data file is : <br>
``` 
wget --no-check-certificate https://gws-access.jasmin.ac.uk/public/nemo/sette_inputs/r4.2.0_LITE/ORCA2_OFF_v4.2.0_LITE.tar.gz  . 
```
Data file is also available on Datarmor :  /home1/datawork/ctalandi/RUN-ORCA2-OFF-TRC/ORCA2_OFF_v4.2.0_LITE <br>
It's a climatological forcing which is provided with the ORCA2 grid domain configuration. <br>
- dyna_grid_T.nc  : 3D salinity and temperature
- dyna_grid_U.nc  : 3D zonal velocity 
- dyna_grid_V.nc  : 3D meridional velocity 
- dyna_grid_W.nc  : 3D vertical velocity as the vertical turbulent diffusivity 
- ORCA_R2_zps_domcfg.nc : the fglobal ORCA2 grid 

Namelists are there [./RUNNING/NAMELISTS] and XML files, to manage NetCDF ouput variables as the output frequency as well, are there [./RUNNING/XML]<br>

Against the original ocean namelist_cfg, 2 things have been changed: <br>
- The name on few input variables:<br>
```
   sn_tem      = 'dyna_grid_T'           ,       120.        , 'votemper'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_sal      = 'dyna_grid_T'           ,       120.        , 'vosaline'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_mld      = 'dyna_grid_T'           ,       120.        , 'somxl010'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_emp      = 'dyna_grid_T'           ,       120.        , 'sowaflup'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_empb     = 'dyna_grid_T'           ,       120.        , 'sowaflup'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_fmf      = 'dyna_grid_T'           ,       120.        , 'iowaflup'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_rnf      = 'dyna_grid_T'           ,       120.        , 'sorunoff'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_ice      = 'dyna_grid_T'           ,       120.        , 'soicecov'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_qsr      = 'dyna_grid_T'           ,       120.        , 'soshfldo'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_wnd      = 'dyna_grid_T'           ,       120.        , 'sowindsp'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_uwd      = 'dyna_grid_U'           ,       120.        , 'uocetr_eff',    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_vwd      = 'dyna_grid_V'           ,       120.        , 'vocetr_eff',    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_wwd      = 'dyna_grid_W'           ,       120.        , 'wocetr_eff',    .true.   , .true. , 'yearly'  , ''               , ''       , ''
   sn_avt      = 'dyna_grid_W'           ,       120.        , 'votkeavt'  ,    .true.   , .true. , 'yearly'  , ''               , ''       , ''
``` 
- the option ln_linssh has been set to .true. <br>

---
## 4 - SUBMISSION:<br>
The job (with a header dedicated to DATARMOR)) OFF-ORCA2_datarmor.sh is available there [./RUNNING/OFF-ORCA2_datarmor.sh] <br>
It is provided as a template and need to be adapted to your own ddirectories, login and so on ...<br>
To submit this job: <br>
```
qsub OFF-ORCA2_datarmor.sh
```

By default a 10-year long imulation from 1960 to 1969 that is performed with 5d mean outputs and 1 file for each year named TRACERS_5d_xxxx0101_xxxx1231_trc.nc . <br>

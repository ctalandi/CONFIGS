#!/bin/bash
date
set -x
########################################################################
#       2. PATHNAME   AND  VARIABLES INITIALISATION                    #
##^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^#
# Some FLAGS (formely deduced from cpp.options) 1= yes, 0= no
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# non standard features (even in DRAKKAR) ( no namelist nor cpp keys defined for that ! ) 
 UBAR_TIDE=0                          # 2D tidal bottom friction
 WAFDMP=0                             # Use WAter Flux DaMPing ( read previous SSS damping climatology in a file)

 RST_SKIP=1                           # if set, checking of the existence of the full set of restart files is disable (save time !)
 # next flags should be set to 1 if using DCM rev > 1674, to 0 otherwise.
 RST_DIRS=1                           # if set, assumes that restart files are written on multiple directories.
 RST_READY=1                          # if set assumes that restart file are ready to be read by NEMO (no links).
 SCALARS=1 			      # To post-treat first monthly mean scalar files 

#########################################################################

 CONFIG=CREG025.L75
 CASE=N420OFFTRC
 CONFIG_CASE=${CONFIG}-${CASE}

# Environmemt and miscelaneous
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
login_node=node    # usefull on jade or an any machines requiring scp or ssh to access remote data
MAILTO=ctalandi@ifremer.fr
ACCOUNT=none       # account number for project submission (e.g curie, vayu ...)
QUEUE=none         # queue name (e.g. curie )

# Directory names
#~~~~~~~~~~~~~~~~
# 
PDIR=/home1/datahome/ctalandi/RUNS
WORKDIR=/home1/scratch/$USER
TMPDIR=$SCRATCH/TMPDIR_${CONFIG_CASE}
MACHINE=datarmor

case  $MACHINE  in
( occigen  ) SUBMIT=sbatch  ;;
( irene    ) SUBMIT=ccc_msub ;;
( ada      ) SUBMIT=SUBMIT=llsubmit ;;
( datarmor ) SUBMIT=qsub ;;
( *        )  echo $MACHINE not yet supported for SUBMIT definition
esac

SUBMIT_SCRIPT=${CONFIG_CASE}_datarmor.sh   # name of the script to be launched by run_nemo in CTL

if [ ! -d ${TMPDIR} ] ; then mkdir $TMPDIR ; fi

#
# Directory on the storage file system (F_xxx)
F_S_DIR=${DATAWORK}/${CONFIG}/${CONFIG_CASE}-S       # Stockage
F_R_DIR=${DATAWORK}/${CONFIG}/${CONFIG_CASE}-R       # Restarts
F_R_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/CONFIGS/${CONFIG}/${CONFIG_CASE}-R       # Restarts
F_I_DIR=${DATAWORK}/${CONFIG}/${CONFIG}-I            # Initial + data
F_DTA_DIR=${DATAWORK}/${CONFIG}/${CONFIG}-I          # data dir
#F_FOR_DIR=/home/datawork-lops-drakkarcom/DATA-REFERENCE/DFS5.2_RD/ALL
F_FOR_DIR=/home/datawork-lops-drakkarcom/DATA-REFERENCE/ERA5-FORCING/ROOT-FILES_DROWNED_NP/ALL
#F_FOR_DIR=/home/datawork-lops-drakkarcom/DATA-REFERENCE/ERA5-FORCING/ADAPTED/CREG025.L75/ALL
F_OBC_DIR=${DATAWORK}/${CONFIG}/${CONFIG}-I/OBC      # OBC files
F_BDY_DIR=${DATAWORK}/${CONFIG}/${CONFIG}-I/BDY      # BDY files
F_RNF_DIR=${DATAWORK}/${CONFIG}/${CONFIG}-I/RUNOFFS/IA
#F_RNF_DIR=${DATAWORK}/${CONFIG}/${CONFIG}-I/RUNOFFS/IA
F_MASK_DIR=${DATAWORK}/${CONFIG}/${CONFIG}-I/MASK    # AABW damping , Katabatic winds
F_INI_DIR=${DATAWORK}/${CONFIG}/${CONFIG}-I/          
F_WEI_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/${CONFIG}-F
F_IWM_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/DATA_FORCING/IWM

F_OBS_DIR=/ccc/work/cont003/drakkar/drakkar      # for OBS operator
  F_ENA_DIR=${P_OBS_DIR}/ENACT-ENS
  F_SLA_DIR=${P_OBS_DIR}/j2

# Directories on the production machine (P_xxx)
P_S_DIR=$WORKDIR/${CONFIG}/${CONFIG_CASE}-S
P_R_DIR=$WORKDIR/${CONFIG}/${CONFIG_CASE}-R
P_I_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/${CONFIG}-I
P_DTA_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/${CONFIG}-I
P_WEI_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/${CONFIG}-F
#P_FOR_DIR=/home/datawork-lops-drakkarcom/DATA-REFERENCE/DFS5.2_RD/ALL
P_FOR_DIR=/home/datawork-lops-drakkarcom/DATA-REFERENCE/ERA5-FORCING/ROOT-FILES_DROWNED_NP/ALL
#P_FOR_DIR=/home/datawork-lops-drakkarcom/DATA-REFERENCE/ERA5-FORCING/ADAPTED/CREG025.L75/ALL
P_OBC_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/DATA_FORCING/BDYS/IA-GLORYS12V1/ALL/
P_BDY_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/DATA_FORCING/BDYS/IA-GLORYS12V1/ALL/
#P_OBC_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/DATA_FORCING/BDYS/IA-GJM189/ALL/
#P_BDY_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/DATA_FORCING/BDYS/IA-GJM189/ALL/
#P_RNF_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/DATA_FORCING/RUNOFFS/IA
P_RNF_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/DATA_FORCING/RUNOFFS/HYDROGFD
P_IWM_DIR=/home/datawork-lops-drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/${CONFIG}/DATA_FORCING/IWM

P_CTL_DIR=${PDIR}/RUN_${CONFIG}/${CONFIG_CASE}/CTL      # directory from which the job is  launched
P_CDF_DIR=${PDIR}/RUN_${CONFIG}/${CONFIG_CASE}/CTL/CDF  # directory from which the diags are launched
P_EXE_DIR=${PDIR}/RUN_${CONFIG}/${CONFIG_CASE}/EXE      # directory where to find opa
P_UTL_DIR=${WORKDIR}                                    # root directory of the build_nc programs (under bin )
P_XIOS_DIR=/home1/datahome/ctalandi/DEV/XIOS/xios-trunk_r2320  # root directory of the XIOS library and xios_server.exe

P_OBS_DIR=/ccc/work/cont003/drakkar/drakkar     # for OBS operation
P_ENA_DIR=${P_OBS_DIR}/ENACT-ENS
P_SLA_DIR=${P_OBS_DIR}/j2

# RUNTOOLS environment is set together with HOMEDCM when installing DCM
RUNTOOLS=/home1/datahome/ctalandi/DEV/GITREP/DCM_4.0/RUNTOOLS

# Executable code
#~~~~~~~~~~~~~~~~
EXEC=$P_EXE_DIR/nemo4.exe                              # nemo ...
XIOS_EXEC=$P_XIOS_DIR/bin/xios_server.exe              # xios server (used if code compiled with key_iomput
MERGE_EXEC=/home1/datawork/ctalandi/WTOOLS/tools/REBUILD_MPP/mergefile_mpp4.exe           # rebuild program (REBUILD_MPP TOOL)  either on the fly (MERGE=1) 
                                                       # or in specific job (MERGE=0). MERGE and corresponding cores number
                                                       # are set in CTL/${SUBMIT_SCRIPT}
                                                       # if you want netcdf4 output use mergefile_mpp4.exe

# In the following, set the name of some files that have a hard coded name in NEMO. Files with variable names
# are directly set up in the corresponding namelist, the script take care of them.
# For the following files, if not relevant set the 'world' name to ''
# set specific file names (data )(world name )                 ;   and their name in NEMO
#--------------------------------------------------------------------------------------------------------
# Ice damping  ! not available in si3 
ICEDMP=                                                        ; NEMO_ICEDMP=ice_damping.nc

# Sub-basin mask for diaptr diags ( mask should include  atlmsk pacmsk indmsk variables
SUBBAS=                                                        ; NEMO_SUBBAS=subbasins.nc

# AHM coef file LDF (dyn)
AHM2D=                                                         ; NEMO_AHM2D=eddy_viscosity_2D.nc
AHM3D=                                                         ; NEMO_AHM3D=eddy_viscosity_3D.nc

# AHT coef file LDF (dyn)
AHT2D=                                                         ; NEMO_AHT2D=eddy_diffusivity_2D.nc
AHT3D=                                                         ; NEMO_AHT3D=eddy_diffusivity_3D.nc

# Tidal mixing (Delavergne)
MXP_BOT=CREG025.L75_mixing_power_bot_20220617.nc               ; NEMO_MXP_BOT=CREG025.L75_mixing_power_bot_20220617.nc
MXP_CRI=CREG025.L75_mixing_power_cri_20220617.nc               ; NEMO_MXP_CRI=CREG025.L75_mixing_power_cri_20220617.nc
MXP_SHO=CREG025.L75_mixing_power_sho_20220617.nc               ; NEMO_MXP_SHO=CREG025.L75_mixing_power_sho_20220617.nc
MXP_NSQ=CREG025.L75_mixing_power_nsq_20220617.nc               ; NEMO_MXP_NSQ=CREG025.L75_mixing_power_nsq_20220617.nc

DSC_BOT=CREG025.L75_decay_scale_bot_20220627.nc                ; NEMO_DSC_BOT=CREG025.L75_decay_scale_bot_20220627.nc
DSC_CRI=CREG025.L75_decay_scale_cri_20221027.nc                ; NEMO_DSC_CRI=CREG025.L75_decay_scale_cri_20221027.nc

# Geothermal flux
GEO=                                                           ; NEMO_GEO=geothermal_heating.nc

# TRACER new CFC file ends in 2005  ( probably obsolete or not up to date )
CFC=                                                           ; NEMO_CFC=cfc1112.atm
CO2=                                                           ; NEMO_CO2=splco2.dat
C14=                                                           ; NEMO_C14=c14.dat

# --- not standard but already used in some config --
# Water flux damping 
WAFDMP_CLIM=                                                   ; NEMO_WAFDMP_CLIM=wdmp_from_MJM95.nc


# My additional input files, there are copied from nemo4.sh script  located there DCM_4.0/RUNTOOLS/lib
# So need to add associated lines into nemo4.sh script
MYADDFI=1

ICEINI=CREG025.L75_PIOMAS_y1979_Z.nc                                              ;  NEMO_ICEINI=CREG025.L75_PIOMAS_y1979_Z.nc
#ICEINI=CREG025_SOSIE-CREG12_drowned_ORCA12.L46-MAL95_y1998-2007m01_icemod.nc      ;  NEMO_ICEINI=CREG025_SOSIE-CREG12_drowned_ORCA12.L46-MAL95_y1998-2007m01_icemod.nc
WOA09SST=woa09_sst01-12_monthly_1deg_t_an_CMA_drowned_Ex_L75.nc                   ;  NEMO_WOA09SST=woa09_sst01-12_monthly_1deg_t_an_CMA_drowned_Ex_L75.nc
RESH_WOA09SST=SST_reshape_WOA09_REG1toCREG025_bilin.nc                            ;  NEMO_RESH_WOA09SST=SST_reshape_WOA09_REG1toCREG025_bilin.nc

# ------------------------------------------------------

# Agrif 
# ======
AGRIF_FIXED_GRID=                                     ; NEMO_AGRIF_FIXED_GRID=AGRIF_FixedGrids.in

# Control parameters
# -----------------
MAXSUB=15            # resubmit job till job $MAXSUB

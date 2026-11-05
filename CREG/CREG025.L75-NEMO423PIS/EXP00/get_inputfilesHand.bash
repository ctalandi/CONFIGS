#/bin/bash
set -xv 

# BIO initial state relies on FREEBIORYS data from year 1993
rsync -rlt  /scale/project/drakkarcom/SIMULATION-OUTPUTS/MERCATOR/FREEBIORYS2V4/INIT/CREG025.L75/1993/FREEBIORYS2V4-CREG025.L75_*.nc .

# Get the following specific BIO files :
# 	- par_fraction_gewex_clim90s00s_daily_CREG025.L75.nc 
# 	- pmarge_etopo_CREG025.L75.nc 
# 	- river_global_news_CREG025.L75.nc 
# 	- ndeposition_Duce_annual_eORCA1-r360x180.nc 
# 	- dust.orca.nc 
# 	- weights_2D_r360x180_CREG025_bilinear.nc 
rsync -rlt /scale/project/drakkarcom/SIMULATION-OUTPUTS/FREDY/CONFIGS/CREG025.L75/CREG025.L75-BIO/*.nc . 

# Other files taht are not managed through the DCM 
rsync  -lrt /scale/project/drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/CREG025.L75/CREG025.L75-I/woa09_CTsst01-12_monthly_1deg_CT_CMA_drowned_Ex_L75_SM5.nc .
rsync -rlt /scale/project/drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/CREG025.L75/DATA_FORCING/BDYS/IA-GLORYS12V1/ALL/FREEBIORYS2V4_BERING_CLIM-1993-2020.1m_*.nc .
rsync -rlt /scale/project/drakkarcom/SIMULATION-OUTPUTS/FREDY/RUNS/CREG025.L75/DATA_FORCING/BDYS/IA-GLORYS12V1/ALL/FREEBIORYS2V4_SUBTROPGYRE_CLIM-1993-2020.1m_*.nc .
rsync -rlt /scale/project/drakkarcom/SIMULATION-OUTPUTS/MERCATOR/FREEBIORYS2V4/MODIFIED/ALL/FREEBIORYS2V4_BERING.1m_*_y199*.nc  .
rsync -rlt /scale/project/drakkarcom/SIMULATION-OUTPUTS/MERCATOR/FREEBIORYS2V4/MODIFIED/ALL/FREEBIORYS2V4_SUBTROPGYRE.1m_*_y199*.nc  .


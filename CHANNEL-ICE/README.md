# CHANNEL-ICE configuration
Gather here all required files to be able to run this configuration

1 - COMPILATION:<br> 
2 - INPUT FILES:<br>
3 - SUBMISSION: <br>
  
---
## 1 - COMPILATION: <br>

Main directory /home1/datahome/ctalandi/DEV/GITREP/DCM_4.0/DCMTOOLS/NEMOREF/nemo_4.2.0/ <br>
Make sure that right librairies have been dowloaded with  B4_compilation.bash <br>
Launch the compilation with lcompile.bash <br>
```
./makenemo -a 'CANAL' -d 'OCE ICE' -n 'MY_ICE_CANAL' -m X64_DATARMORMPI -j 128 add_key 'key_si3 key_mpi2 key_linssh' del_key 'key_qco'
```

Specific code changes:<br>
/home1/datahome/ctalandi/DEV/GITREP/DCM_4.0/DCMTOOLS/NEMOREF/nemo_4.2.0/tests/MY_ICE_CANAL/MY_SRC<br>
Includin the comented lines done by Clement to test one thing about the vertical diffusion eq. and residual term associated to the convergence of the solver

Cpp keys:<br>
 key_xios  key_si3  key_mpi2  key_linssh<br>


---
## 2 - INPUT FILES:<br>
Directory: /home1/datahome/ctalandi/DEV/ICE-CHANNEL <br>
Namelists and XML files <br>
Initial state: **Channel_Oce_pt_noise_pS_1000_5000_grid_freezing_point_75m_lin_strat_depth_6months.nc** <br>
Surface forcing: **Channel-Surf-Forcing_new_ALL_seasonal_new_grid_HR_HTR_out_boundaries_april_center_no_atm_temp_moving.nc** <br>
These 2 files are also there: /home1/datawork/ctalandi/CHANEL-ICE/ICE-BUG <br>

---
## 3 - SUBMISSION:<br>

directory  /home1/datawork/ctalandi/CHANEL-ICE/ICE-BUG <br>
Job: qsub Job-Channel.pbs <br>

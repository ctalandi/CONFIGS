# eORCA025.L75-OFF-LINE configuration
Gather here all required files to be able to run this configuration. <br>
It has been built from the eORCA025.L75-IMHOTEP.GAI configuration but with our own pasive tracer.<br>

0 - GENERAL INFORMATION:<br>
1 - DCM + NEMO CODE & XIOS:<br>
2 - BUILD A NEW CONFIGURATION & COMPILE:<br> 
3 - INPUT FILES:<br>
4 - JOB SUBMISSION: <br>
5 - RESULTS: <br>
6 - ANALYSE: <br>
7 - MISC: <br>
  
---
## 0 - GENERAL INFORMATION: <br>
Since this new OFF-LINE configuration is using input data from the early eORCA025.L75-IMHOTEP.GAI, it has been built 
following the [DCM](https://github.com/meom-group/DCM/blob/4.2/DOC/dcm_getting_started.md) environment that has been used 
to built it as all scripts for submitting it on the IDRIS superconmputer [Jean-Zay](http://www.idris.fr/jean-zay/) as well.  <br>

### 0.1 COMPUTING TIME RESSOURCES:
For a 31 days simulation:<br> 
```
JobID           JobName  Partition      State  Timelimit               Start                 End    Elapsed   NNodes      NCPUS        NodeList 
------------ ---------- ---------- ---------- ---------- ------------------- ------------------- ---------- -------- ---------- --------------- 
205350         nemo_OFF     cpu_p1  COMPLETED   01:05:00 2023-06-22T11:20:05 2023-06-22T11:25:46   00:05:41       36       2880 r1i0n[5-6,22,3+ 
205350.batch      batch             COMPLETED            2023-06-22T11:20:05 2023-06-22T11:25:46   00:05:41        1         80          r1i0n5 
205350.exte+     extern             COMPLETED            2023-06-22T11:20:05 2023-06-22T11:25:46   00:05:41       36       2880 r1i0n[5-6,22,3+ 
205350.0     ztask_fil+             COMPLETED            2023-06-22T11:20:09 2023-06-22T11:25:44   00:05:35       36       2880 r1i0n[5-6,22,3+
```
5.68  x 36 nodes x 40 cores =  8179.2'  ~136.32 hCPus elapsed for 31 days <br>
This leads to __1605 hCpus elapsed time for 1-year long simulation__.  <br>

### 0.2 OFF-LINE CODE CALLING SEQUENCE:
General information on the calling subroutine sequence into the code to better understand the key steps.<br>

- At the initialisation step in dta_dyn_init() & when NOT in ln_linssh, 2 fields are required:<br>
			- horizontal divergence <br>
			- empb = E-P before field  (I guess )<br>
- When the ln_trabbl option is selected, 2 velocities fields are also required: <br>
- Vertical scales factors are reconstructed based on the sshn field read in the restart file <br>


Calling tree of the Off-line:<br>
```
nemogcm.F90 
	- nemo_init() 
		- dta_dyn_init()  rebuild e3x with sshn() & sshb() fields read in restart file. read hdiv & empb in restart file 
	- Time loop
		- dta_dyn(istp)
			- read all required fields  among which 2D emp_b and 3D horizontal divergence
			- dta_dyn_ssh()  = compute the e3t_a() & ssha  as well  using the 2 previous fields 
		- trc_stp(istp)
			- trc_trp()
			- trc_sms()
```

The code block corresponding to the use of empb field in the dya_dyn subroutine<br>
```
     IF( .NOT.ln_linssh ) THEN
         ALLOCATE( zemp(jpi,jpj) , zhdivtr(jpi,jpj,jpk) )
         zhdivtr(:,:,:) = sf_dyn(jf_div)%fnow(:,:,:)  * tmask(:,:,:)    ! effective u-transport
         emp_b  (:,:)   = sf_dyn(jf_empb)%fnow(:,:,1) * tmask(:,:,1)    ! E-P
         zemp   (:,:)   = ( 0.5_wp * ( emp(:,:) + emp_b(:,:) ) + rnf(:,:) + fwbcorr ) * tmask(:,:,1)
         CALL dta_dyn_ssh( kt, zhdivtr, sshb, zemp, ssha, e3t_a(:,:,:) )  !=  ssh, vertical scale factor & vertical transport
         DEALLOCATE( zemp , zhdivtr )
```

In the next section, information about how to install the DCM environment and the XIOS library, to build a configuration.<br>


---
## 1 - DCM + NEMO CODE & XIOS : <br>

All the following has been done o the Jean-Zay superconmputer of [IDRIS](http://www.idris.fr).

### 1.1 DCM installation:  
All information about DCM is [there](https://github.com/meom-group/DCM/blob/4.2/DOC/dcm_getting_started.md). <br>
On the HOMEDIR:
```
cd /linkhome/rech/genlop01/rost832/
mkdir DEV 
cd DEV
git clone https://github.com/meom-group/DCM.git DCM_4.0

```

Then to switch to a specific commit or tag or whatever hereafter it relies on the 4.0.6 DCM release : <br>
```
cd DCM_4.0
commit=f6983d83c6ebfd3c766b47b78aa21ab40eaacb87
git checkout $commit
```

Then download the corresponding NEMO code revision:<br>
```
cd /linkhome/rech/genlop01/rost832/DEV/DCM_4.0/DCMTOOLS/NEMOREF
module load svn 
./getnemoref.sh

Checked out revision 14608.
```

Then to load the corresponding module, add the following line (changing the pathway to your own one) in your .bashrc . <br>
export MODULEPATH="$MODULEPATH:/gpfs7kw/linkhome/rech/genlop01/yourlogin/modules" replace the login with yours. <br>
Then copy the /linkhome/rech/genlop01/rost832/modules/DCM/4.0.6 file into the same directory modules/DCM/<br>
And set the paths to your own ones <br>

Also add the following lines in the .bashrc

```
alias mkconfdir=$HOMEDCM/bin/dcm_mkconfdir_remote

export UDIR=$HOME/CONFIGS/
export PDIR=$HOME/RUNS/
export CDIR=$WORK
export SDIR=$STORE
export DDIR=$SCRATCH
```

### 1.2  XIOS library :
To be able to perform model outputs, the XIOS library is used. <br>

Get a XIOS version as close as possible as the one effectively used for IMHOTEP: <br>
```
cd $WORK
mkdir XIOS 
cd XIOS 
svn co https://forge.ipsl.jussieu.fr/ioserver/svn/XIOS2/branches/xios-2.5 xios-2.5
```

The corresponding revision was 2503: <br>
```
cd xios-2.5
./make_xios --full --arch X64_JEANZAY -j 64
```

Then the path to access to  this library has to be set into the includefile.sh  through the  P_XIOS_DIR variable: /gpfswork/rech/hjl/rost832/XIOS/xios-2.5 . <br>

---
## 2 - BUILD A NEW CONFIGURATION & COMPILE: <br>
In the following is described how to build a new confugration in using the DCM environment scripts and how to compile it. <br>
Let's build the eORCA025.L75-OFF configuration and the RUN1 experiment name.<br>
From you home directory for instance:<br>

```
mkconfdir  eORCA025.L75-OFF   RUN1 
cd ~/CONFIGS/CONFIG_eORCA025.L75-OFF/eORCA025.L75-OFF-RUN1
```

Edit the CPP.key file and set the following cpp keys:
```
key_iomput
key_mpp_mpi
key_netcdf4
key_top

```

Edit the makefile & set the different following variables:<br>
``` 
PREV_CONFIG = '/linkhome/rech/genlgg01/rcli002/CONFIGS/CONFIG_eORCA025.L75/eORCA025.L75-IMHOTEP.GAI'

MACHINE = X64_JEANZAY_jm

NCOMPIL_PROC = 64

TOP = 'use'
OFF = 'use'
```
Then copy also file in which all compilationn options are set [./CODE/ARCH/X64_JEANZAY_jm.fcm](./CODE/ARCH/X64_JEANZAY_jm.fcm) :<br>
```
cp /linkhome/rech/genlop01/rost832/CONFIGS/CONFIG_eORCA025.L75-OFF/eORCA025.L75-OFF-RUN1/arch-X64_JEANZAY_jm.fcm ./arch/.
```

Ensure that the proper libraires and tools listed in [./CODE/B4_COMPILATION.txt](./CODE/B4_COMPILATION.txt) are loaded: <br>
```
module purge
module load intel-compilers/19.0.4 intel-mkl/19.0.4 intel-mpi/19.0.4
module load hdf5/1.10.5-mpi
module load netcdf/4.7.2-mpi
module load netcdf-fortran/4.5.2-mpi
module load ncview/2.1.8
module load nco/4.9.3
module load DCM/4.0.6
```

Then copy all specific F90 modules used for the eORCA025.L75-IMHOTEP.GAI configuration localy: <br>
This step is required only once for a given configration.<br>
```
make copyconfig
```
This command line allows to duplicate all F90 modules from the eORCA025.L75-IMHOTEP.GAI configuration set through the variable PREV_CONFIG in the makefile. <br>

After that get all files that you would like to adapt for your purpose with the dcm_getfile command line , e.g. <br>
```
dcm_getfile trcnam_my_trc.F90
```
Once all required F90 modules required for the current configuration are ready, the configuration can be built. <br>

```
make install
```

Then compile the new configuration: <br>
```
make 
```

---
## 3 - INPUT FILES:<br>

Basic paths to get code, input data from Jean-Marc login:<br>
- Usefull yearly restart files are stored there: /gpfsstore/rech/cli/rcli002/eORCA025.L75/eORCA025.L75-IMHOTEP.GAI-R
- All others required files are there: /gpfswork/rech/cli/rcli002/eORCA025.L75/eORCA025.L75-I
- Data from 2000 are duplicated there from JMM space: /gpfsstore/rech/hjl/rost832/CONFIGS/CONFIG_eORCA025.L75-OFF/eORCA025.L75-IMHOTEP.GAI-S/1d/2000-concat

For the current test all required files are stored there: /gpfswork/rech/hjl/rost832/CONFIG/eORCA025.L75-OFF/eORCA025.L75-OFF-I<br>

List of file type that have been provided to the offline configuration through the namdta_dyn ocean namelist block:<br>
```
!-----------------------------------------------------------------------
&namdta_dyn    !   offline ocean input files                            (OFF_SRC only)
!-----------------------------------------------------------------------
   ln_dynrnf       =  .false.    !  runoffs option enabled (T) or not (F)
   ln_dynrnf_depth =  .false.    !  runoffs is spread in vertical (T) or not (F)
!   fwbcorr        = 3.786e-06   !  annual global mean of empmr for ssh correction

   cn_dir      = './'      !  root directory for the ocean data location
   !___________!_________________________!___________________!___________!_____________!________!___________!__________________!__________!_______________!
   !           !  file name              ! frequency (hours) ! variable  ! time interp.!  clim  ! 'yearly'/ ! weights filename ! rotation ! land/sea mask !
   !           !                         !  (if <0  months)  !   name    !   (logical) !  (T/F) ! 'monthly' !                  ! pairing  !    filename   !
   sn_tem      = 'eORCA025.L75-IMHOTEP.GAI_1d_gridT' , 24.   , 'votemper'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_sal      = 'eORCA025.L75-IMHOTEP.GAI_1d_gridT' , 24.   , 'vosaline'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_mld      = 'eORCA025.L75-IMHOTEP.GAI_1d_flxT'  , 24.   , 'somixhgt'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_emp      = 'eORCA025.L75-IMHOTEP.GAI_1d_flxT'  , 24.   , 'sowaflup'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_fmf      = 'eORCA025.L75-IMHOTEP.GAI_1d_icemod', 24.   , 'vfxice'    ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_ice      = 'eORCA025.L75-IMHOTEP.GAI_1d_icemod', 24.   , 'siconc'    ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_qsr      = 'eORCA025.L75-IMHOTEP.GAI_1d_flxT'  , 24.   , 'soshfldo'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_wnd      = 'eORCA025.L75-IMHOTEP.GAI_1d_flxT'  , 24.   , 'sowinsp'   ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_uwd      = 'eORCA025.L75-IMHOTEP.GAI_1d_gridU' , 24.   , 'vozocrtx'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_vwd      = 'eORCA025.L75-IMHOTEP.GAI_1d_gridV' , 24.   , 'vomecrty'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_wwd      = 'eORCA025.L75-IMHOTEP.GAI_1d_gridW' , 24.   , 'vovecrtz'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_avt      = 'eORCA025.L75-IMHOTEP.GAI_1d_gridW' , 24.   , 'voavt'     ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_ubl      = 'dyna_grid_U'           ,       120.        , 'sobblcox'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
   sn_vbl      = 'dyna_grid_V'           ,       120.        , 'sobblcoy'  ,  .true.   , .false. , 'monthly'  , ''               , ''       , ''
/
```


---
## 4 - JOB SUBMISSION:<br>
Since we have been using the DCM environment, Everything is described on the [DCM](https://github.com/meom-group/DCM/blob/4.2/DOC/dcm_rt_manual.md) web page.<br>
Focus directly on the "Starting with DCM's runtools"  section. <br>
Under the directory RUNS/RUN_eORCA025.L75-OFF/eORCA025.L75-OFF-RUN1/CTL put all following files:<br>

List of the 4 files to deal with to submit a job: <br>
- [eORCA025.L75-OFF-RUN1.GAI.db](./RUNNING/eORCA025.L75-OFF-RUN1.GAI.db):  To set the iteration number depending the model time step <br>
- [includefile.sh](./RUNNING/includefile.sh): to set all paths and input files that are required for a given experiment <br>
- [eORCA025.L75-OFF-RUN1_jean-zay.sh](./RUNNING/eORCA025.L75-OFF-RUN1_jean-zay.sh): the job itself with mainly a header dedicated to the computing ressources <br>
- [run_nemo.sh](./RUNNING/run_nemo.sh): the script to launch the job itself. Use it in command line ./run_nemo.sh <br>

---
## 5 - RESULTS:<br>
Update November 2023: <br>
The model is waiting for transport components, not velocities. So the trcadv.F90 has to be modified to do so. <br> 
This solves the initial problem. <br>

September 2023: <br>
Based on this configuration, a problem has been identified. <br>
It seems that the advective components are tiny leading the lateral and vertical diffusivity to be the major trends on the full advective diffusive equation.<br>
A test permformed with ORCA2 using the last NEMO release 4.2.0 show results that are more expected.<br>
Investigation are under process (2023-09).<br>

---
## 6 - ANALYSE:<br>
Notebooks developped by Anne Gaymard during a M2 interneship are also available under the [ANALYSE](./ANALYSE/) directory.   <br>

---
## 7 - MISC:<br>
Other information arond the IMHOTEP input data:<br> 

Email from Jean-MArc 2023-05-17: <br>
```
Les sources sont dans /linkhome/rech/genlgg01/rcli002/CONFIGS/CONFIG_eORCA025.L75/eORCA025.L75-IMHOTEP.GAI sur Jean-Zay.Pour 
Claude, qui comprendra ( ;) ), ces sources utilisent le DCM/4.0.6  au commit f6983d83c6ebfd3c766b47b78aa21ab40eaacb87 sur GitHub.Le repertoire de 
contole de ce run (où on retrouve toutes les infos necessaires pour faire tourner la configuration ) est :
/gpfswork/rech/cli/rcli002/RUNS/RUN_eORCA025.L75/eORCA025.L75-IMHOTEP.GAI/CTL/
```

To download a specific commit from a git repository using a hashtag: <br>
```
commit=26911cc471c9316f7a67495d4fd544dce35b758d
git clone git@forge.nemo-ocean.eu:nemo/nemo.git NEMO4
cd NEMO4 ; git checkout $commit
```
Email from Jean-MArc 2023-03-20: <br>
```
J'ai en principe mis les ACL pour que tu puisses acceder aux sorties.

Par exemple le membre 1 est sous /gpfsstore/rech/cli/rcli002/eORCA025.L75/eORCA025.L75-IMHOTEP.EGAI.001-S   ( le .001 donne le membre,  eg 008 = membre 8)
Les sorties 3D sont a 5J dans le repertoire 5d. Pour chaque année, il y a un repertoire <YEAR>-concat qui contient des fichiers annuels (73 time frame).
Les sorties à 5 jours sont des moyennes à 5 jours.
Pour les années bissextiles, on a toujours 73 frames, mais la frame qui contient le 29 février est une moyenne à 6 jours. (la variable time_counter est bien documentée et pointe sur le milieu de la période de 5jours).

Enfin, dans le WP1 IMHOTEP, nous avons réalisé des simulation monomembres, avec des sorties 3D à 1jours  L’équivalent de EGAI est GAI  sous
/gpfsstore/rech/cli/rcli002/eORCA025.L75/eORCA025.L75-IMHOTEP.GAI-S/
repertoire 1d/ 1 repertoire par année, fichiers concaténé par mois

Tant pour GAI que EGAI on retrouve les meme type de fichiers, les champs 3D étant les gridT gridU et gridV. 

Entre EGAI et GAI il y a une difference au niveau des forcages atmosphériques: Pour le run d'ensemble le forcage est commun aux 10 membres et correspond à la moyenne d'ensemble des forcages (calculé pour chaque membre avec les formules bulk NCAR).

Ces runs n'ont pas de rappel en SSS.  En revanche, un premier run à été réalisé avec un rappel en SSS et on a conservé ce terme de rappel pour l'utiliser ensuite comme une correction de précipitation.
  Dans le run monomembre, on a utilisé une moyenne mensuelle avec variabilié interannuelle pour ce terme de correction
 Dans le run d'ensemble, on a utilisé une moyenne mensuelle climatologique pour ce terme de correction (suite à une discussion avec Jerome Vialard) ce qui libere la variabilité interannuelle.
```

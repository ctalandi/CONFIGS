MODULE trcini_my_trc
   !!======================================================================
   !!                         ***  MODULE trcini_my_trc  ***
   !! TOP :   initialisation of the MY_TRC tracers
   !!======================================================================
   !! History :        !  2007  (C. Ethe, G. Madec) Original code
   !!                  !  2016  (C. Ethe, T. Lovato) Revised architecture
   !!----------------------------------------------------------------------
   !! trc_ini_my_trc   : MY_TRC model initialisation
   !!----------------------------------------------------------------------
   USE par_trc         ! TOP parameters
   USE oce_trc
   USE trc
   USE par_my_trc
   USE trcnam_my_trc     ! MY_TRC SMS namelist
   USE trcsms_my_trc

   IMPLICIT NONE
   PRIVATE

   PUBLIC   trc_ini_my_trc   ! called by trcini.F90 module

   !!----------------------------------------------------------------------
   !! NEMO/TOP 4.0 , NEMO Consortium (2018)
   !! $Id: trcini_my_trc.F90 10068 2018-08-28 14:09:04Z nicolasmartin $ 
   !! Software governed by the CeCILL license (see ./LICENSE)
   !!----------------------------------------------------------------------
CONTAINS

   SUBROUTINE trc_ini_my_trc
      !!----------------------------------------------------------------------
      !!                     ***  trc_ini_my_trc  ***  
      !!
      !! ** Purpose :   initialization for MY_TRC model
      !!
      !! ** Method  : - Read the namcfc namelist and check the parameter values
      !!----------------------------------------------------------------------
      !
      CALL trc_nam_my_trc
      !
      !                       ! Allocate MY_TRC arrays
      IF( trc_sms_my_trc_alloc() /= 0 )   CALL ctl_stop( 'STOP', 'trc_ini_my_trc: unable to allocate MY_TRC arrays' )

      IF(lwp) WRITE(numout,*)
      IF(lwp) WRITE(numout,*) ' trc_ini_my_trc: passive tracer unit vector'
      IF(lwp) WRITE(numout,*) ' To check conservation : '
      IF(lwp) WRITE(numout,*) '   1 - No sea-ice model '
      IF(lwp) WRITE(numout,*) '   2 - No runoff ' 
      IF(lwp) WRITE(numout,*) '   3 - precipitation and evaporation equal to 1 : E=P=1 ' 
      IF(lwp) WRITE(numout,*) ' ~~~~~~~~~~~~~~'
      
      IF( .NOT. ln_rsttr ) THEN
              trn(:,:,:,jp_myt0:jp_myt1) = 0.
              !trn(900:1000,900:1000,:,jp_myt0:jp_myt1) = 1.
              !trn( mi0(900):mi1(1000) , mj0(900):mj1(1000),1,jp_myt0:jp_myt1) = 1.
              trn( mi0(935):mi1(955) , mj0(947):mj1(954),1,jp_myt0:jp_myt1) = 10000. !zone 0: courant du Lab
              trn( mi0(977):mi1(979) , mj0(949):mj1(952),1,jp_myt0:jp_myt1) = 10000. !zone 1: lon_min=-43.75 ;lon_max=43.25 ;lat_min=55.5 ;lat_max=56
              trn( mi0(977):mi1(979) , mj0(899):mj1(902),1,jp_myt0:jp_myt1) = 10000. !zone 2: lon_min=-43.75 ;lon_max=43.25 ;lat_min=47.25 ;lat_max=47.75
              trn( mi0(977):mi1(979) , mj0(799):mj1(802),1,jp_myt0:jp_myt1) = 10000. !zone 3: lon_min=-43.75 ;lon_max=43.25 ;lat_min=27.5 ;lat_max=28
      ENDIF
      !
   END SUBROUTINE trc_ini_my_trc

   !!======================================================================
END MODULE trcini_my_trc

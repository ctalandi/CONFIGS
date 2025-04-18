MODULE trcadv
   !!==============================================================================
   !!                       ***  MODULE  trcadv  ***
   !! Ocean passive tracers:  advection trend 
   !!==============================================================================
   !! History :  2.0  !  2005-11  (G. Madec)  Original code
   !!            3.0  !  2010-06  (C. Ethe)   Adapted to passive tracers
   !!            3.7  !  2014-05  (G. Madec, C. Ethe)  Add 2nd/4th order cases for CEN and FCT schemes 
   !!            4.0  !  2017-09  (G. Madec)  remove vertical time-splitting option
   !!----------------------------------------------------------------------
#if defined key_top
   !!----------------------------------------------------------------------
   !!   'key_top'                                                TOP models
   !!----------------------------------------------------------------------
   !!   trc_adv       : compute ocean tracer advection trend
   !!   trc_adv_ini   : control the different options of advection scheme
   !!----------------------------------------------------------------------
   USE par_trc        ! need jptra, number of passive tracers
   USE oce_trc        ! ocean dynamics and active tracers
   USE trc            ! ocean passive tracers variables
   USE sbcwave        ! wave module
   USE sbc_oce        ! surface boundary condition: ocean
   USE traadv_cen     ! centered scheme           (tra_adv_cen  routine)
   USE traadv_fct     ! FCT      scheme           (tra_adv_fct  routine)
   USE traadv_mus     ! MUSCL    scheme           (tra_adv_mus  routine)
   USE traadv_ubs     ! UBS      scheme           (tra_adv_ubs  routine)
   USE traadv_qck     ! QUICKEST scheme           (tra_adv_qck  routine)
   USE tramle         ! ML eddy induced transport (tra_adv_mle  routine)
   USE ldftra         ! lateral diffusion: eddy diffusivity & EIV coeff.
   USE ldfslp         ! Lateral diffusion: slopes of neutral surfaces
   !
   USE prtctl         ! control print
   USE timing         ! Timing

   IMPLICIT NONE
   PRIVATE

   PUBLIC   trc_adv       ! called by trctrp.F90
   PUBLIC   trc_adv_ini   ! called by trcini.F90

   !                            !!* Namelist namtrc_adv *
   LOGICAL ::   ln_trcadv_OFF    ! no advection on passive tracers
   LOGICAL ::   ln_trcadv_cen    ! centered scheme flag
   INTEGER ::      nn_cen_h, nn_cen_v   ! =2/4 : horizontal and vertical choices of the order of CEN scheme
   LOGICAL ::   ln_trcadv_fct    ! FCT scheme flag
   INTEGER ::      nn_fct_h, nn_fct_v   ! =2/4 : horizontal and vertical choices of the order of FCT scheme
   LOGICAL ::   ln_trcadv_mus    ! MUSCL scheme flag
   LOGICAL ::      ln_mus_ups           ! use upstream scheme in vivcinity of river mouths
   LOGICAL ::   ln_trcadv_ubs    ! UBS scheme flag
   INTEGER ::      nn_ubs_v             ! =2/4 : vertical choice of the order of UBS scheme
   LOGICAL ::   ln_trcadv_qck    ! QUICKEST scheme flag

   INTEGER ::   nadv             ! choice of the type of advection scheme
   !                             ! associated indices:
   INTEGER, PARAMETER ::   np_NO_adv  = 0   ! no T-S advection
   INTEGER, PARAMETER ::   np_CEN     = 1   ! 2nd/4th order centered scheme
   INTEGER, PARAMETER ::   np_FCT     = 2   ! 2nd/4th order Flux Corrected Transport scheme
   INTEGER, PARAMETER ::   np_MUS     = 3   ! MUSCL scheme
   INTEGER, PARAMETER ::   np_UBS     = 4   ! 3rd order Upstream Biased Scheme
   INTEGER, PARAMETER ::   np_QCK     = 5   ! QUICK scheme
   
   !! * Substitutions
#  include "do_loop_substitute.h90"
#  include "domzgr_substitute.h90"
   !!----------------------------------------------------------------------
   !! NEMO/TOP 4.0 , NEMO Consortium (2018)
   !! $Id: trcadv.F90 15073 2021-07-02 14:20:14Z clem $ 
   !! Software governed by the CeCILL license (see ./LICENSE)
   !!----------------------------------------------------------------------
CONTAINS

   SUBROUTINE trc_adv( kt, Kbb, Kmm, ptr, Krhs  )
      !!----------------------------------------------------------------------
      !!                  ***  ROUTINE trc_adv  ***
      !!
      !! ** Purpose :   compute the ocean tracer advection trend.
      !!
      !! ** Method  : - Update after tracers (tr(Krhs)) with the advection term following nadv
      !!----------------------------------------------------------------------
      INTEGER                                   , INTENT(in)    :: kt   ! ocean time-step index
      INTEGER                                   , INTENT(in)    :: Kbb, Kmm, Krhs ! time level indices
      REAL(wp), DIMENSION(jpi,jpj,jpk,jptra,jpt), INTENT(inout) :: ptr            ! passive tracers and RHS of tracer equation
      !
      INTEGER ::   ji, jj, jk   ! dummy loop index
      CHARACTER (len=22) ::   charout
      REAL(wp), DIMENSION(jpi,jpj,jpk) ::   zuu, zvv, zww  ! effective velocity
      !!----------------------------------------------------------------------
      !
      IF( ln_timing )   CALL timing_start('trc_adv')
      !
      !                                         !==  effective transport  ==!
      IF( l_offline ) THEN
!CT CREG025.L75
         DO_3D( nn_hls, nn_hls-1, nn_hls, nn_hls-1, 1, jpk )
            zuu(ji,jj,jk) = e2u(ji,jj) * e3u(ji,jj,jk,Kmm) * uu(ji,jj,jk,Kmm)             ! already in (uu(Kmm),vv(Kmm),ww)
            zvv(ji,jj,jk) = e1v(ji,jj) * e3v(ji,jj,jk,Kmm) * vv(ji,jj,jk,Kmm)
         END_3D
         DO_3D( nn_hls-1, nn_hls-1, nn_hls-1, nn_hls-1, 1, jpk )
            zww(ji,jj,jk) = e1e2t(ji,jj) * ww(ji,jj,jk)
         END_3D
!CT         DO_3D( nn_hls, nn_hls-1, nn_hls, nn_hls-1, 1, jpk )
!CT            zuu(ji,jj,jk) = uu(ji,jj,jk,Kmm)             ! already in (uu(Kmm),vv(Kmm),ww)
!CT            zvv(ji,jj,jk) = vv(ji,jj,jk,Kmm)
!CT         END_3D
!CT         DO_3D( nn_hls-1, nn_hls-1, nn_hls-1, nn_hls-1, 1, jpk )
!CT            zww(ji,jj,jk) = ww(ji,jj,jk)
!CT         END_3D
!CT CREG025.L75
      ELSE                                         ! build the effective transport
         DO_2D( nn_hls, nn_hls-1, nn_hls, nn_hls-1 )
            zuu(ji,jj,jpk) = 0._wp
            zvv(ji,jj,jpk) = 0._wp
         END_2D
         DO_2D( nn_hls-1, nn_hls-1, nn_hls-1, nn_hls-1 )
            zww(ji,jj,jpk) = 0._wp
         END_2D
         IF( ln_wave .AND. ln_sdw )  THEN
            DO_3D( nn_hls, nn_hls-1, nn_hls, nn_hls-1, 1, jpkm1 )                            ! eulerian transport + Stokes Drift
               zuu(ji,jj,jk) = e2u  (ji,jj) * e3u(ji,jj,jk,Kmm) * ( uu(ji,jj,jk,Kmm) + usd(ji,jj,jk) )
               zvv(ji,jj,jk) = e1v  (ji,jj) * e3v(ji,jj,jk,Kmm) * ( vv(ji,jj,jk,Kmm) + vsd(ji,jj,jk) )
            END_3D
            DO_3D( nn_hls-1, nn_hls-1, nn_hls-1, nn_hls-1, 1, jpkm1 )
               zww(ji,jj,jk) = e1e2t(ji,jj)                     * ( ww(ji,jj,jk)     + wsd(ji,jj,jk) )
            END_3D
         ELSE
            DO_3D( nn_hls, nn_hls-1, nn_hls, nn_hls-1, 1, jpkm1 )
               zuu(ji,jj,jk) = e2u  (ji,jj) * e3u(ji,jj,jk,Kmm) * uu(ji,jj,jk,Kmm)           ! eulerian transport
               zvv(ji,jj,jk) = e1v  (ji,jj) * e3v(ji,jj,jk,Kmm) * vv(ji,jj,jk,Kmm)
            END_3D
            DO_3D( nn_hls-1, nn_hls-1, nn_hls-1, nn_hls-1, 1, jpkm1 )
               zww(ji,jj,jk) = e1e2t(ji,jj)                     * ww(ji,jj,jk)
            END_3D
         ENDIF
         !
         IF( ln_vvl_ztilde .OR. ln_vvl_layer ) THEN                                          ! add z-tilde and/or vvl corrections
            DO_3D( nn_hls, nn_hls-1, nn_hls, nn_hls-1, 1, jpkm1 )
               zuu(ji,jj,jk) = zuu(ji,jj,jk) + un_td(ji,jj,jk)
               zvv(ji,jj,jk) = zvv(ji,jj,jk) + vn_td(ji,jj,jk)
            END_3D
         ENDIF
         !
         IF( ln_ldfeiv .AND. .NOT. ln_traldf_triad )   & 
            &              CALL ldf_eiv_trp( kt, nittrc000, zuu, zvv, zww, 'TRC', Kmm, Krhs )  ! add the eiv transport
         !
         IF( ln_mle    )   CALL tra_mle_trp( kt, nittrc000, zuu, zvv, zww, 'TRC', Kmm       )  ! add the mle transport
         !
      ENDIF
      !
      SELECT CASE ( nadv )                      !==  compute advection trend and add it to general trend  ==!
      !
      CASE ( np_CEN )                                 ! Centered : 2nd / 4th order
         CALL tra_adv_cen   ( kt, nittrc000,'TRC',          zuu, zvv, zww,      Kmm, ptr, jptra, Krhs, nn_cen_h, nn_cen_v )
      CASE ( np_FCT )                                 ! FCT      : 2nd / 4th order
            CALL tra_adv_fct( kt, nittrc000,'TRC', rDt_trc, zuu, zvv, zww, Kbb, Kmm, ptr, jptra, Krhs, nn_fct_h, nn_fct_v )
      CASE ( np_MUS )                                 ! MUSCL
            CALL tra_adv_mus( kt, nittrc000,'TRC', rDt_trc, zuu, zvv, zww, Kbb, Kmm, ptr, jptra, Krhs, ln_mus_ups         )
      CASE ( np_UBS )                                 ! UBS
         CALL tra_adv_ubs   ( kt, nittrc000,'TRC', rDt_trc, zuu, zvv, zww, Kbb, Kmm, ptr, jptra, Krhs, nn_ubs_v           )
      CASE ( np_QCK )                                 ! QUICKEST
         CALL tra_adv_qck   ( kt, nittrc000,'TRC', rDt_trc, zuu, zvv, zww, Kbb, Kmm, ptr, jptra, Krhs                     )
      !
      END SELECT
      !                  
      IF( sn_cfctl%l_prttrc ) THEN        !== print mean trends (used for debugging)
         WRITE(charout, FMT="('adv ')")
         CALL prt_ctl_info( charout, cdcomp = 'top' )
         CALL prt_ctl( tab4d_1=tr(:,:,:,:,Krhs), mask1=tmask, clinfo=ctrcnm, clinfo3='trd' )
      END IF
      !
      IF( ln_timing )   CALL timing_stop('trc_adv')
      !
   END SUBROUTINE trc_adv


   SUBROUTINE trc_adv_ini
      !!---------------------------------------------------------------------
      !!                  ***  ROUTINE trc_adv_ini  ***
      !!                
      !! ** Purpose :   Control the consistency between namelist options for 
      !!              passive tracer advection schemes and set nadv
      !!----------------------------------------------------------------------
      INTEGER ::   ioptio, ios   ! Local integer
      !!
      NAMELIST/namtrc_adv/ ln_trcadv_OFF,                        &   ! No advection
         &                 ln_trcadv_cen, nn_cen_h, nn_cen_v,    &   ! CEN
         &                 ln_trcadv_fct, nn_fct_h, nn_fct_v,    &   ! FCT
         &                 ln_trcadv_mus, ln_mus_ups,            &   ! MUSCL
         &                 ln_trcadv_ubs,           nn_ubs_v,    &   ! UBS
         &                 ln_trcadv_qck                             ! QCK
      !!----------------------------------------------------------------------
      !
      !                                !==  Namelist  ==!
      READ  ( numnat_ref, namtrc_adv, IOSTAT = ios, ERR = 901)
901   IF( ios /= 0 )   CALL ctl_nam ( ios , 'namtrc_adv in reference namelist' )
      READ  ( numnat_cfg, namtrc_adv, IOSTAT = ios, ERR = 902 )
902   IF( ios >  0 )   CALL ctl_nam ( ios , 'namtrc_adv in configuration namelist' )
      IF(lwm) WRITE ( numont, namtrc_adv )
      !
      IF(lwp) THEN                           ! Namelist print
         WRITE(numout,*)
         WRITE(numout,*) 'trc_adv_ini : choice/control of the tracer advection scheme'
         WRITE(numout,*) '~~~~~~~~~~~'
         WRITE(numout,*) '   Namelist namtrc_adv : chose a advection scheme for tracers'
         WRITE(numout,*) '      No advection on passive tracers           ln_trcadv_OFF = ', ln_trcadv_OFF
         WRITE(numout,*) '      centered scheme                           ln_trcadv_cen = ', ln_trcadv_cen
         WRITE(numout,*) '            horizontal 2nd/4th order               nn_cen_h   = ', nn_fct_h
         WRITE(numout,*) '            vertical   2nd/4th order               nn_cen_v   = ', nn_fct_v
         WRITE(numout,*) '      Flux Corrected Transport scheme           ln_trcadv_fct = ', ln_trcadv_fct
         WRITE(numout,*) '            horizontal 2nd/4th order               nn_fct_h   = ', nn_fct_h
         WRITE(numout,*) '            vertical   2nd/4th order               nn_fct_v   = ', nn_fct_v
         WRITE(numout,*) '      MUSCL scheme                              ln_trcadv_mus = ', ln_trcadv_mus
         WRITE(numout,*) '            + upstream scheme near river mouths    ln_mus_ups = ', ln_mus_ups
         WRITE(numout,*) '      UBS scheme                                ln_trcadv_ubs = ', ln_trcadv_ubs
         WRITE(numout,*) '            vertical   2nd/4th order               nn_ubs_v   = ', nn_ubs_v
         WRITE(numout,*) '      QUICKEST scheme                           ln_trcadv_qck = ', ln_trcadv_qck
      ENDIF
      !
      !                                !==  Parameter control & set nadv ==!
      ioptio = 0
      IF( ln_trcadv_OFF ) THEN   ;   ioptio = ioptio + 1   ;   nadv = np_NO_adv   ;   ENDIF
      IF( ln_trcadv_cen ) THEN   ;   ioptio = ioptio + 1   ;   nadv = np_CEN      ;   ENDIF
      IF( ln_trcadv_fct ) THEN   ;   ioptio = ioptio + 1   ;   nadv = np_FCT      ;   ENDIF
      IF( ln_trcadv_mus ) THEN   ;   ioptio = ioptio + 1   ;   nadv = np_MUS      ;   ENDIF
      IF( ln_trcadv_ubs ) THEN   ;   ioptio = ioptio + 1   ;   nadv = np_UBS      ;   ENDIF
      IF( ln_trcadv_qck ) THEN   ;   ioptio = ioptio + 1   ;   nadv = np_QCK      ;   ENDIF
      !
      IF( ioptio /= 1 )   CALL ctl_stop( 'trc_adv_ini: Choose ONE advection option in namelist namtrc_adv' )
      !
      IF( ln_trcadv_cen .AND. ( nn_cen_h /= 2 .AND. nn_cen_h /= 4 )   &
                        .AND. ( nn_cen_v /= 2 .AND. nn_cen_v /= 4 )   ) THEN
        CALL ctl_stop( 'trc_adv_ini: CEN scheme, choose 2nd or 4th order' )
      ENDIF
      IF( ln_trcadv_fct .AND. ( nn_fct_h /= 2 .AND. nn_fct_h /= 4 )   &
                        .AND. ( nn_fct_v /= 2 .AND. nn_fct_v /= 4 )   ) THEN
        CALL ctl_stop( 'trc_adv_ini: FCT scheme, choose 2nd or 4th order' )
      ENDIF
      IF( ln_trcadv_ubs .AND. ( nn_ubs_v /= 2 .AND. nn_ubs_v /= 4 )   ) THEN
        CALL ctl_stop( 'trc_adv_ini: UBS scheme, choose 2nd or 4th order' )
      ENDIF
      IF( ln_trcadv_ubs .AND. nn_ubs_v == 4 ) THEN
         CALL ctl_warn( 'trc_adv_ini: UBS scheme, only 2nd FCT scheme available on the vertical. It will be used' )
      ENDIF
      IF( ln_isfcav ) THEN                                                       ! ice-shelf cavities
         IF(  ln_trcadv_cen .AND. nn_cen_v == 4    .OR.   &                            ! NO 4th order with ISF
            & ln_trcadv_fct .AND. nn_fct_v == 4   )   CALL ctl_stop( 'tra_adv_ini: 4th order COMPACT scheme not allowed with ISF' )
      ENDIF
      !
      !                                !==  Print the choice  ==!  
      IF(lwp) THEN
         WRITE(numout,*)
         SELECT CASE ( nadv )
         CASE( np_NO_adv  )   ;   WRITE(numout,*) '      ===>>   NO passive tracer advection'
         CASE( np_CEN     )   ;   WRITE(numout,*) '      ===>>   CEN      scheme is used. Horizontal order: ', nn_cen_h,   &
            &                                                                     ' Vertical   order: ', nn_cen_v
         CASE( np_FCT     )   ;   WRITE(numout,*) '      ===>>   FCT      scheme is used. Horizontal order: ', nn_fct_h,   &
            &                                                                      ' Vertical   order: ', nn_fct_v
         CASE( np_MUS     )   ;   WRITE(numout,*) '      ===>>   MUSCL    scheme is used'
         CASE( np_UBS     )   ;   WRITE(numout,*) '      ===>>   UBS      scheme is used'
         CASE( np_QCK     )   ;   WRITE(numout,*) '      ===>>   QUICKEST scheme is used'
         END SELECT
      ENDIF
      !
   END SUBROUTINE trc_adv_ini
   
#endif

  !!======================================================================
END MODULE trcadv

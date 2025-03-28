
!load in global data shift to Arctic

program wrap

use netcdf

implicit none


integer :: nx, ny, nz
double precision, pointer, dimension(:,:) :: h,h2

! ADAPT THE FOLLOWING TWO LINES. 
integer :: ni=528, nj=603              ! x and y-dimensions of new domain
! Now define the corner of the new domain in the global domain
integer :: ista=54, jsta=604, jdiff=0  ! ista: distance from middle (x-direction)
                                       ! jsta: distance from lower boundary
                 ! jsta is valid for eastern and western boundary in x-direction (lower and upper
                 ! margin of regional domain)! Use the smaller value! 
                 ! if index of western boundary (lower regional) is higher than 
                 ! index of eastern (upper regional) use jdiff for difference, 
                 ! else set jdiff=0 
integer status
integer ncid, varid, ncout, dimx, dimy, dimz, ndims, nvars, itype, ipos, varout, ilen, k
integer, dimension(4) :: kdimsz, ddims, istart, icount
!integer iargc
integer nargc
integer :: natts, attid
character(len=255) :: clname, cdname
character(len=80) :: varname, attname, attvalue
character(len=1) :: cname
logical first
real :: attreal
double precision attdouble
integer attint
integer(KIND=2) :: attshort
integer(KIND=1) :: attbyte

!----------------------------------------------------------
! check argument list
!----------------------------------------------------------

nargc=iargc()
if (nargc < 2) then
  write(*,*) 'Usage: inpfile outfile'
  stop
endif

!----------------------------------------------------------
! read argument list
!----------------------------------------------------------

 call getarg(1,clname)
 call getarg(2,cdname)

!----------------------------------------------------------
! open netcdf file in read mode
!----------------------------------------------------------


      status=NF90_OPEN ( TRIM(clname), NF90_NOWRITE, ncid )
      if (status/=0) then
          write(*,*) 'bad opening of file : ',TRIM(clname)
          stop
      endif

      status=NF90_INQUIRE(ncid,ndims,nvars)
      status=NF90_INQ_VARID         (ncid, "vomecrty", varid)
      if (status/=0) then
          write(*,*) 'variable vomecrty not found'
          stop
      endif

!----------------------------------------------------------
! find original dimensions and allocate
!----------------------------------------------------------

      status=NF90_INQUIRE_VARIABLE  (ncid, varid, dimids=kdimsz)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(1), len=nx)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(2), len=ny)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(3), len=nz)
      write(*,*) 'kdimsz', kdimsz
      write(*,*) 'found dimensions : ',nx,ny,nz


allocate(h (nx,ny))
allocate(h2(ni,nj))

!----------------------------------------------------------
!create output file
!----------------------------------------------------------

      status=NF90_CREATE( TRIM(cdname), NF90_CLOBBER, ncout )
      ! define dimensions
      status=NF90_DEF_DIM( ncout, 'x', ni, dimx )
      status=NF90_DEF_DIM( ncout, 'y', nj, dimy )
      status=NF90_DEF_DIM( ncout, 'z', nz, dimz )
      first=.false.
      status=NF90_ENDDEF( ncout )

!----------------------------------------------------------
! loop over all variables
!----------------------------------------------------------

 DO varid = 1, nvars
    status=NF90_INQUIRE_VARIABLE(ncid, varid, varname, itype, ndims, ddims, natts)   ! number of dimensions


     write(*,*) 'varname:', varname

! jump over undesired variables
    if ( varname == 'nav_lon' .or. varname == 'nav_lat' .or. varname == 'x' .or. varname == 'y' .or.  &
         varname == 'sometauy' .or. varname == 'time_instant' .or. varname == 'time_instant_bounds' .or. varname == 'time_counter' .or. &
         varname == 'time_centered' .or. varname == 'depthv' .or. varname == 'deptht_bounds' .or. varname == 'deptht' .or. & 
         varname == 'axis_nbounds' ) cycle


    IF  ( varname == 'vomecrty' )   then
    	status=NF90_REDEF( ncout )
        ddims(1)=dimx; ddims(2)=dimy ; ddims(3)=dimz
    	status=NF90_DEF_VAR( ncout, TRIM(varname), itype, ddims(1:3), varout )
        status=NF90_ENDDEF( ncout )

    	write(*,*) 'copy attributes'
    	DO attid = 1, natts
    	   status=NF90_INQ_ATTNAME( ncid, varid, attid, attname )
           write(*,*) 'natts:', natts
           write(*,*) 'attname:', attname
           write(*,*) 
           write(*,*) 
    	   status=NF90_INQUIRE_ATTRIBUTE( ncid,  varid, TRIM(attname), xtype=itype )
    	   select case(itype)
    	   case( NF90_BYTE )
    	     status=NF90_GET_ATT( ncid,  varid, TRIM(attname), attbyte )
    	     status=NF90_PUT_ATT( ncout, varout, TRIM(attname), attbyte )
    	     write(*,*) '     attributes : ',varid, ',',TRIM(attname), ',',itype,attbyte
    	   case( NF90_SHORT )
    	     status=NF90_GET_ATT( ncid,  varid, TRIM(attname), attshort )
    	     status=NF90_PUT_ATT( ncout, varout, TRIM(attname), attshort )
    	     write(*,*) '     attributes : ',varid, ',',TRIM(attname), ',',itype,attshort
    	   case( NF90_INT )
    	     status=NF90_GET_ATT( ncid,  varid, TRIM(attname), attint )
    	     status=NF90_PUT_ATT( ncout, varout, TRIM(attname), attint )
    	     write(*,*) '     attributes : ',varid, ',',TRIM(attname), ',',itype,attint
    	   case( NF90_FLOAT )
    	     status=NF90_GET_ATT( ncid,  varid, TRIM(attname), attreal )
    	     status=NF90_PUT_ATT( ncout, varout, TRIM(attname), attreal )
    	     write(*,*) '     attributes : ',varid, ',',TRIM(attname), ',',itype,attreal
    	   case( NF90_DOUBLE )
    	     status=NF90_GET_ATT( ncid,  varid, TRIM(attname), attdouble )
    	     status=NF90_PUT_ATT( ncout, varout, TRIM(attname), attdouble )
    	     write(*,*) '     attributes : ',varid, ',',TRIM(attname), ',',itype,attdouble
    	   case ( NF90_CHAR )
    	     status=NF90_GET_ATT( ncid,  varid, TRIM(attname), attvalue )
    	     status=NF90_PUT_ATT( ncout, varout, TRIM(attname), TRIM(attvalue) )
    	     write(*,*) '     attributes : ',varid, ',',TRIM(attname), ',',itype,TRIM(attvalue)
    	   end select
    	ENDDO

    	ilen = len( TRIM(varname) )
    	cname=varname(ilen:ilen)

    	write(*,*) 'variable : ',varid, ',',TRIM(varname), ',',cname

    	  do k=1,nz
    	     istart(:)=1; icount(:)=1;
    	     istart(3)=k;
    	     icount(1)=nx; icount(2)=ny;
    	     status=NF90_GET_VAR(ncid, varid, h, istart, icount)
    	     call wrap_grid_v(nx,ny,h,ni,nj,h2,ista,jsta,jdiff)
    	     icount(1)=ni; icount(2)=nj;
    	     status=NF90_PUT_VAR( ncout, varout, h2, istart, icount)

             if(status /= nf90_noerr) write(*,*) TRIM(NF90_STRERROR(status))
             write(*,*) 'write',k,varout,status
    	  enddo

    ENDIF

  ENDDO ! loop over variables

status=NF90_CLOSE( ncid )
status=NF90_CLOSE( ncout )

end


subroutine wrap_grid_v(nx,ny,hold,ninew,njnew,hnew,ista,jsta,jdiff)
implicit none
!argumens
integer nx,ny
double precision, dimension(nx,ny) :: hold
integer ninew,njnew
double precision, dimension(ninew,njnew) :: hnew
! locals
double precision, allocatable, dimension(:,:) :: h1
integer jsta,jend,jmid,j0,nj,ni,iend,ista,jdiff,njsta,j2
integer i,j

! shift--------------------------

jend=ny
jmid=jend-jsta
j0=jend-2

ni=nx/2
nj=jend-jsta+1
allocate(h1(ni,nj+jmid-2))
h1(1:ni,1:nj-2)=hold(nx/2+1:nx,jsta:jend-2)

do j=1,jmid
 j2=max(jend-j-1,1)
 do i=1,ni
    h1(i,j+nj-2)=-1.*hold(nx/2+1-i+1,j2)
 enddo
enddo

iend=ista+ninew-1  
njsta=jdiff+1                       
jend=njsta+njnew-1         

hnew=h1(ista:iend,njsta:jend);
deallocate(h1)

return
end


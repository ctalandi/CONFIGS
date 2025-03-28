
!load in global data shift to Arctic

program wrap

use netcdf

implicit none

integer :: nx, ny, nz, nt
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
integer ncid, varid, ncout, dimx, dimy, dimz, dimt, ndims, nvars, itype, ipos, varout, ilen, k, it
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
  write(*,*) 'Usage: infile outfile'
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
      status=NF90_INQ_VARID         (ncid, "votemper", varid)
      if (status/=0) then
          write(*,*) 'variable votemper not found'
          stop
      endif

!----------------------------------------------------------
! find original dimensions and allocate
!----------------------------------------------------------

      status=NF90_INQUIRE_VARIABLE  (ncid, varid, dimids=kdimsz)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(1), len=nx)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(2), len=ny)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(3), len=nz)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(4), len=nt)
      write(*,*) 'kdimsz', kdimsz
      write(*,*) 'found dimensions : ',nx,ny,nz,nt


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
      status=NF90_DEF_DIM( ncout, 'time_counter', NF90_UNLIMITED, dimt )
      first=.false.
      status=NF90_ENDDEF( ncout )

!----------------------------------------------------------
! loop over all variables
!----------------------------------------------------------

 DO varid = 1,nvars
    status=NF90_INQUIRE_VARIABLE(ncid, varid, name = varname, xtype = itype, ndims=ndims, dimids=ddims, nAtts=natts)   ! number of dimensions

     write(*,*) 'varname:', varname

! jump over undesired variables
    if ( varname == 'x' .or. varname == 'y' .or. varname == 'e3t' .or. varname == 'time_instant' .or. varname == 'time_instant_bounds' .or. & 
         varname == 'time_counter' .or. varname == 'time_centered' .or. varname == 'sossheig' .or. varname == 'deptht_bounds' .or. varname == 'deptht' .or. & 
         varname == 'axis_nbounds' .or. varname == 'nav_lev') cycle

    IF ( varname == 'nav_lat' .or. varname == 'nav_lon' .or. varname == 'vosaline' .or. varname == 'votemper' )  then
        if ( ndims == 2 ) then ; ddims(1)=dimx ; ddims(2)=dimy ; endif
        if ( ndims == 4 ) then ; ddims(1)=dimx ; ddims(2)=dimy ; ddims(3)=dimz ; ddims(4)=dimt ; endif
    	status=NF90_REDEF( ncout )
    	status=NF90_DEF_VAR( ncout, TRIM(varname), itype, ddims(1:ndims), varout )
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
	write(*,*)'nz, nt, ndims :',nz,nt, ndims

	select case (ndims)

        case(2) ! 2D fields, no time_counter

    	       istart(:)=1; icount(:)=1;
    	       icount(1)=nx; icount(2)=ny;
               status=NF90_GET_VAR(ncid, varid, h, istart, icount)
    	       call wrap_grid_t(nx,ny,h,ni,nj,h2,ista,jsta,jdiff)
               icount(1)=ni; icount(2)=nj;
               status=NF90_PUT_VAR( ncout, varout, h2, istart, icount)

	case (4)   ! 4th dimensions, 3rd axis is vertical axis, 4th axis is time_counter 
    		do it=1,nt
    		  do k=1,nz
    		     istart(:)=1; icount(:)=1;
    		     istart(3)=k; istart(4)=it;
    		     icount(1)=nx; icount(2)=ny;
    		     status=NF90_GET_VAR(ncid, varid, h, istart, icount)
    		     call wrap_grid_t(nx,ny,h,ni,nj,h2,ista,jsta,jdiff)
    		     icount(1)=ni; icount(2)=nj;
    		     status=NF90_PUT_VAR( ncout, varout, h2, istart, icount)

        	     if(status /= nf90_noerr) write(*,*) TRIM(NF90_STRERROR(status))
        	     write(*,*) 'write',it,k,varout,status
    		  enddo
    		enddo

        end select

    ENDIF 

 ENDDO    ! loop over the variables

status=NF90_CLOSE( ncid )
status=NF90_CLOSE( ncout )

end


subroutine wrap_grid_t(nx,ny,hold,ninew,njnew,hnew,ista,jsta,jdiff)
implicit none
!arguments
integer nx,ny
double precision, dimension(nx,ny) :: hold
integer ninew,njnew
double precision, dimension(ninew,njnew) :: hnew
! locals
double precision, allocatable, dimension(:,:) :: h1
integer jsta,jend,jmid,j0,nj,ni,iend,ista,jdiff,njsta
integer i,j

! shift--------------------------

jend=ny         ! upper edge in global (ydim of global) 
jmid=jend-jsta  ! ydim of regional part 1
j0=jend-2       ! upper edge minus suture margin 

ni=nx/2         ! half of global xdim
nj=jend-jsta+1  ! from lower boundary to upper edge
allocate(h1(ni,nj+jmid-2)) ! =h1(nx/2,2*nj-3)
h1(1:ni,1:nj-2)=hold(nx/2+1:nx,jsta:jend-2)

do j=1,jmid  ! =1,ny-jsta
 do i=1,ni
    h1(i,j+nj-2)=hold(nx/2+1-i+1,jend-j)
 enddo
enddo

! set limits for regional in h1 (temporary)
iend=ista+ninew-1  
njsta=jdiff+1     
jend=njsta+njnew-1           

hnew=h1(ista:iend,njsta:jend);
deallocate(h1)

return
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
    h1(i,j+nj-2)=hold(nx/2+1-i+1,j2)
 enddo
enddo

iend=ista+ninew-1  
njsta=jdiff+1                       
jend=njsta+njnew-1         

hnew=h1(ista:iend,njsta:jend);
deallocate(h1)

return
end


subroutine wrap_grid_u(nx,ny,hold,ninew,njnew,hnew,ista,jsta,jdiff)
implicit none
!argumens
integer nx,ny
double precision, dimension(nx,ny) :: hold
integer ninew,njnew
double precision, dimension(ninew,njnew) :: hnew
! locals
double precision, allocatable, dimension(:,:) :: h1
integer jsta,jend,jmid,j0,nj,ni,iend,ista,jdiff,njsta
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
 do i=1,ni
    h1(i,j+nj-2)=hold(nx/2+1-i,jend-j)
 enddo
enddo

iend=ista+ninew-1  
njsta=jdiff+1
jend=njsta+njnew-1           

hnew=h1(ista:iend,njsta:jend);
deallocate(h1)

return
end


subroutine wrap_grid_f(nx,ny,hold,ninew,njnew,hnew,ista,jsta,jdiff)
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
    h1(i,j+nj-2)=hold(nx/2+1-i,j2)
 enddo
enddo

iend=ista+ninew-1  
njsta=jdiff+1
jend=njsta+njnew-1           

hnew=h1(ista:iend,njsta:jend);
deallocate(h1)

return
end




!load in global data shift to Arctic

program wrap

use netcdf

implicit none

integer :: nx, ny
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
integer ncid, varid, ncout, dimx, dimy, ndims, nvars, itype, ipos, varout, ilen
integer, dimension(4) :: kdimsz, ddims, istart, icount
!integer iargc
integer nargc
character(len=255) :: clname, cdname
character(len=80) :: varname
character(len=1) :: cname
logical first

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
      status=NF90_INQ_VARID         (ncid, "nav_lon", varid)
      if (status/=0) then
          write(*,*) 'variable nav_lon not found'
          stop
      endif

!----------------------------------------------------------
! find original dimensions and allocate
!----------------------------------------------------------

      status=NF90_INQUIRE_VARIABLE  (ncid, varid, dimids=kdimsz)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(1), len=nx)
      status=NF90_INQUIRE_DIMENSION (ncid, kdimsz(2), len=ny)
      write(*,*) 'found dimensions : ',nx,ny


allocate(h (nx,ny))
allocate(h2(ni,nj))

!----------------------------------------------------------
!create output file
!----------------------------------------------------------

      status=NF90_CREATE( TRIM(cdname), NF90_CLOBBER, ncout )
      ! define dimensions
      status=NF90_DEF_DIM( ncout, 'x', ni, dimx )
      status=NF90_DEF_DIM( ncout, 'y', nj, dimy )
      first=.false.
      status=NF90_ENDDEF( ncout )

!----------------------------------------------------------
! loop over all variables
!----------------------------------------------------------

 DO varid = 1,nvars
    status=NF90_INQUIRE_VARIABLE(ncid, varid, name = varname, xtype = itype)   ! number of dimensions

! jump over undesired variables
    if ( varname == 'nav_lev' .or. varname == 'x' .or. varname == 'y' .or.  &
         varname == 'time'    .or. varname == 'time_steps' ) cycle

    status=NF90_GET_VAR(ncid, varid, h)

    ilen = len( TRIM(varname) )
    cname=varname(ilen:ilen)
!FD debug
  if (varid<5) cname='t'
write(*,*) 'variable : ',varid, ',',TRIM(varname), ',',cname

    select case (cname)
    case('t')
      call wrap_grid_t(nx,ny,h,ni,nj,h2,ista,jsta,jdiff)
    case('u')
      call wrap_grid_u(nx,ny,h,ni,nj,h2,ista,jsta,jdiff)
    case('v')
      call wrap_grid_v(nx,ny,h,ni,nj,h2,ista,jsta,jdiff)
    case('f')
      call wrap_grid_f(nx,ny,h,ni,nj,h2,ista,jsta,jdiff)
    case default
      call wrap_grid_t(nx,ny,h,ni,nj,h2,ista,jsta,jdiff)
    end select

    IF ( TRIM(varname) == 'Bathymetry' ) THEN
        WRITE(*,*) ' Specific treatment for the bathymetry'
        WRITE(*,*) ' ***WARNING*** dependent on chosen jsta, idist, ni, nj'
        ! Fill closed Seas
        ! Gulf of Mexico
        h2(1:51,1:15)=0.e0
        h2(1:46,16:28)=0.e0
        ! Red Sea
        h2(501:528,1:20)=0.e0
        ! Black and Marmara Seas
        h2(482:528,77:130)=0.e0
    END IF



      status=NF90_REDEF( ncout )
      ddims(1)=dimx; ddims(2)=dimy
      status=NF90_DEF_VAR( ncout, TRIM(varname), itype, ddims(1:2), varout )
      if (varname=='Bathymetry') status=NF90_PUT_ATT( ncout, varout, 'units', 'm' )
      status=NF90_ENDDEF( ncout )

    status=NF90_PUT_VAR( ncout, varout, h2)

  ENDDO

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



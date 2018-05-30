program fit
  implicit none
  character(len=50) :: fin1, fin2, fout
  integer, dimension(4) :: ia
  real, dimension(:,:), allocatable :: qgcm, qobs
  real, dimension(:), allocatable:: fieldin, fieldout
  integer :: i, ierr, bound, ncurve

  ncurve=19
  allocate(qgcm(24180,ncurve),qobs(24180,ncurve))

  call arguments(fin1, fin2, fout)

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  READ QQ CURVE
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
open(10, file=fin1, action='read', status='old', form='unformatted')
do i=1, ncurve
  read(10, iostat=ierr) ia
  read(10, iostat=ierr) qgcm(:,i)
  read(10, iostat=ierr) ia
  read(10, iostat=ierr) qobs(:,i)
enddo

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
close(10)

!print*, qobs
!print*, qgcm

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  READ INPUT FIELD CURVE
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
open(20, file=fin2, action='read', status='old', form='unformatted')
read(20, iostat=ierr) ia
allocate(fieldin(ia(4)), fieldout(ia(4)))
rewind(20)
open(30, file=fout, action='write', status='unknown', form='unformatted')
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  ACTUAL CALCULATION
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
do
  read(20, iostat=ierr) ia
  read(20, iostat=ierr) fieldin
  if(ierr/=0) exit

  do i=1, ia(4)
    bound=count(fieldin(i)>qgcm(i,:))
    if(bound.eq.0)then
      fieldout(i)=fieldin(i)
    elseif(bound.gt.0.and.bound.lt.ncurve)then
      fieldout(i)=qobs(i,bound)+(qobs(i,bound+1)-qobs(i,bound)) / (qgcm(i,bound+1)-qgcm(i,bound)) * (fieldin(i)-qgcm(i,bound))
    else
      fieldout(i)=fieldin(i)+(qobs(i,ncurve)-qgcm(i,ncurve))
    endif
  enddo

  write(30, iostat=ierr) ia
  write(30, iostat=ierr) fieldout
enddo

close(20)
close(30)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

print*, 'Ended'
contains

subroutine arguments(fin1, fin2, fout)
  implicit none
  integer :: i
  character(len=50) :: arg, fin1, fin2, fout

  ! Reads the command
  i = 0
  do
  call get_command_argument(i, arg)
  if (len_trim(arg) == 0) exit
  i = i+1
  end do

  ! Check for the number of arguments (they should be 2)
  if(i.ne.4)then
    stop "Wrong usage: qq qqfile.ext input.ext output.ext"
  endif

  ! Convert to integers the date, basic checks for meaningful dates and exit
  call get_command_argument(1, fin1)
  call get_command_argument(2, fin2)
  call get_command_argument(3, fout)
end subroutine

end program

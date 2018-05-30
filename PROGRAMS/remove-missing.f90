program removemissing
  implicit none
  character(len=50) :: fnamein, fnameout, cns, cnt, cnmiss
  integer :: i, j, m,  ns, nt, nmiss
  real, dimension(:), allocatable :: data_raw
  real, dimension(:,:), allocatable :: data

  call arguments(fnamein, fnameout, cns, cnt, cnmiss)

  read(cns,*)ns
  read(cnt,*)nt
  read(cnmiss,*)nmiss

  allocate(data_raw(ns), data(ns-nmiss,nt))

  open(10, file=fnamein, status='old', action='read')
  open(20, file=fnameout, status='unknown', action='write')
  do i=1, nt
    read(10,*) data_raw
    m=1
    do j=1, ns
      if(data_raw(j).lt.-100)cycle
      data(m,i)=data_raw(j)
      m=m+1
    enddo
    write(20,*)data(:,i)
  enddo
  close(20)
  close(10)

!  do i=1,ns-nmiss
!    print*, i, maxval(data(i,:))-minval(data(i,:))
!  enddo

!  do i=1,nt
!    print*, i, maxval(data(:,i))-minval(data(:,i))
!  enddo
  contains


subroutine arguments(fin, fout, cns, cnt, cnmiss)
  implicit none
  integer :: i
  character(len=50) :: arg, fin, fout, cns, cnt, cnmiss

  ! Reads the command
  i = 0
  do
  call get_command_argument(i, arg)
  if (len_trim(arg) == 0) exit
  i = i+1
  end do

  ! Check for the number of arguments (they should be 2)
!  if(i.ne.3)then
!    stop "Wrong usage: hierarchical-clustering.x filein.ext fileout.ext"
!  endif

  ! Convert to integers the date, basic checks for meaningful dates and exit
  call get_command_argument(1, fin)
  call get_command_argument(2, fout)
  call get_command_argument(3, cns)
  call get_command_argument(4, cnt)
  call get_command_argument(5, cnmiss)
end subroutine

end program

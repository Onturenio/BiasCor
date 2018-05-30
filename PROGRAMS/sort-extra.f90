program sort
  implicit none
  real, dimension(19,24180) :: q1,q2
  integer, dimension(4,19) :: ia1, ia2
  character(len=32) :: fin, fout
  integer :: i

  call arguments(fin, fout)

  open(10, file=fin, action='read', status='old', form='unformatted')
  do i=1,19
!  print*, i
    read(10) ia1(:,i)
    read(10) q1(i,:)
  enddo
  do i=1,19
    read(10) ia2(:,i)
    read(10) q2(i,:)
  enddo
  close(10)

  open(20, file=fout, action='write', status='unknown', form='unformatted')
  do i=1,19
!    print*, ia1(:,i)
    write(20) ia1(:,i)
    write(20) q1(i,:)
    write(20) ia2(:,i)
    write(20) q2(i,:)
  enddo
  close(20)

  print*, 'END'

contains

subroutine arguments(fin, fout)
  implicit none
  integer :: i
  character(len=32) :: arg, fin, fout

  ! Reads the command
  i = 0
  do
  call get_command_argument(i, arg)
  if (len_trim(arg) == 0) exit
  i = i+1
  end do

  ! Convert to integers the date, basic checks for meaningful dates and exit
  call get_command_argument(1, fin)
  call get_command_argument(2, fout)
end subroutine



  end program

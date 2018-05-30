implicit none

integer :: i, j, k, l, idum, ix, iy, Simulations
integer, dimension(:), allocatable :: indx
real, dimension(:), allocatable :: dato
real :: ran1, gasdev
real :: beta, x, xmin, xmax, f, bandwidth
integer :: N

idum=-1254484+idum


! N is the size of the sample
! bandwidth is the width of the kernel
! xmin and xmax are set inside this program
N=1000
xmin=-1.5
xmax=1.5
bandwidth=0.1


read(*,*)N
read(*,*)xmin
read(*,*)xmax
read(*,*)bandwidth

allocate(dato(N))


do j=1,N
  read(10,*)dato(j)
enddo

do i=0,1000
  x=xmin+(xmax-xmin)*i/1000
  f=0
  do j=1,N
    !por aqui estoy
    f=f+1/2.5066/bandwidth*exp(-1.0*(x-dato(j))**2/2/bandwidth**2)
  enddo
  print*,x,f/N
enddo

end program

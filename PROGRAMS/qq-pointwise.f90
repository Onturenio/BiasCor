program fit
  implicit none
  character(len=32) :: arg, fin1, fin2, fmask, fout
  integer, dimension(4) :: ia
  integer :: i, j, m, ierr, ntime1, nspace1, ntime2, nspace2, bound1r, bound1l, bound2r, bound2l, nresolution
  integer :: reg, nsize
  real, allocatable, dimension(:,:) :: data1, data2, qfield1, qfield2
  integer, allocatable, dimension(:,:) :: supermask1, supermask2
  integer, allocatable, dimension(:) :: indx1, indx2, imask
  real, allocatable, dimension(:) :: cdf, y, x, data1_pack, data2_pack, mask, q1, q2

  call arguments(fin1, fin2, fmask)
  print*, fin1, fin2, fmask

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!  READ INPUT FILE AND ALLOCATE DATA
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
open(10, file=fin1, action='read', status='old', form='unformatted')
! Obtain data dimensions
i=0
do
  read(10, iostat=ierr) ia
  read(10, iostat=ierr)
  if(ierr/=0) exit
  i=i+1
enddo

rewind(10)

ntime1=i
nspace1=ia(4)

print*, 'Allocating', ntime1,'x',nspace1
allocate(data1(ntime1, nspace1))

! read input file
i=1
do
  read(10, iostat=ierr)
  read(10, iostat=ierr) data1(i,:)
!  print*, count(data1(i,:).gt.-100)
  if(ierr/=0) exit
  i=i+1
enddo
close(10)

open(20, file=fin2, action='read', status='old', form='unformatted')
! Obtain data dimensions
i=0
do
  read(20, iostat=ierr) ia
  read(20, iostat=ierr)
  if(ierr/=0) exit
  i=i+1
enddo

rewind(20)

ntime2=i
nspace2=ia(4)

print*, 'Allocating', ntime2,'x',nspace2
allocate(data2(ntime2, nspace2))

! read input file
i=1
do
  read(20, iostat=ierr)
  read(20, iostat=ierr) data2(i,:)
!  print*, count(data2(i,:).gt.-100)
  if(ierr/=0) exit
  i=i+1
enddo
close(20)

open(30, file=fmask, action='read', status='old', form='unformatted')
read(30, iostat=ierr) ia
allocate(mask(ia(4)), imask(ia(4)))
read(30, iostat=ierr) mask
close(30)

where(mask.lt.-100.or.mask.gt.100) mask=0
imask=int(mask)

!if(ntime1.ne.ntime2) stop 'Temporal dimension does not fit'
if(nspace1.ne.nspace2) stop 'Spatial dimension does not fit'
if(nspace1.ne.size(imask)) stop 'Mask does not fit'

allocate(supermask1(ntime1, size(imask)))
supermask1=spread(imask,1,ntime1)

allocate(supermask2(ntime2, size(imask)))
supermask2=spread(imask,1,ntime2)

nresolution=20
allocate(q1(nresolution-1), &
         q2(nresolution-1), &
         qfield1(nresolution-1, nspace1), &
         qfield2(nresolution-1, nspace2))

qfield1=-9999
qfield2=-9999

do reg=1, 10
  nsize=count(imask.eq.reg)
!  print*, nsize, ntime1, nsize*ntime1
!  print*, count(supermask.eq.reg)

  if(nsize.eq.0) exit
  print*, 'Calculating QQ for region', reg

  if(allocated(data1_pack)) deallocate(data1_pack)
  if(allocated(data2_pack)) deallocate(data2_pack)
  if(allocated(indx1)) deallocate(indx1)
  if(allocated(indx2)) deallocate(indx2)

  allocate(data1_pack(count(supermask1.eq.reg.and.data1.gt.-100)),&
                indx1(count(supermask1.eq.reg.and.data1.gt.-100)), &
           data2_pack(count(supermask2.eq.reg.and.data2.gt.-100)),&
                indx2(count(supermask2.eq.reg.and.data2.gt.-100)))

  data1_pack=pack(data1, mask=supermask1.eq.reg.and.data1.gt.-100)
  data2_pack=pack(data2, mask=supermask2.eq.reg.and.data2.gt.-100)


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!REAL CALCULATION
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  call indexx(size(data1_pack), data1_pack, indx1)
  call indexx(size(data2_pack), data2_pack, indx2)

  do i=1, nresolution-1
    j=i*size(data1_pack)/nresolution
!    print*, 'perc',j, i, i/real(size(data1_pack))*100
    q1(i)=data1_pack(indx1(j))
    q2(i)=data2_pack(indx2(j))
    write(30,*) q1(i), q2(i), reg
  enddo

  do i=1, nspace1
    if(imask(i).eq.reg)then
      qfield1(:,i)=q1
      qfield2(:,i)=q2
    endif
  enddo

enddo
!qfield1(1,5)=1
!qfield1(1,1)=1
!qfield1(1,7)=1
!print*, qfield1(1,1:7)
!print*, average(qfield1(1,1:7))
! do i=1, npa
!stop

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!WRITE OUTPUT FILE
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  do j=1, nresolution-1
    write(20)20000101,1,j,nspace1
    write(20) qfield1(j,:)
    write(20)20000101,2,j,nspace2
    write(20) qfield2(j,:)
  enddo

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

print*, 'End'

contains

real function average(data)
  real, dimension(:), intent(in) :: data

  integer :: i, center
  real, dimension(size(data)) :: weight

  center=(size(data)+1)/2
  do i=1, size(data)
    weight(i)=exp(-(i-center)**2/real(size(data)))
  enddo

  where(data.lt.-100) weight=0
  if(count(data.gt.-100).eq.0)then
    average=-9999
    return
  endif
  weight=weight/sum(weight,mask=data.gt.-100)

  average=dot_product(weight, data)
end function

subroutine arguments(fin1, fin2, fmask)
  implicit none
  integer :: i
  character(len=32) :: arg, fin1, fin2, fmask

  ! Reads the command
  i = 0
  do
  call get_command_argument(i, arg)
  if (len_trim(arg) == 0) exit
  i = i+1
  end do

  ! Check for the number of arguments (they should be 2)
  if(i.ne.4)then
    stop "Wrong usage: fit input1.ext input2.ext mask.ext"
  endif

  ! Convert to integers the date, basic checks for meaningful dates and exit
  call get_command_argument(1, fin1)
  call get_command_argument(2, fin2)
  call get_command_argument(3, fmask)
end subroutine


      subroutine indexx(n,arr,indx)
      implicit none

      integer n,indx(n),m,nstack
      real  arr(n)
      parameter (m=7,nstack=50)
      integer i,indxt,ir,itemp,j,jstack,k,l,istack(nstack)
      real a

      do j=1,nstack
        istack(j)=0
      enddo

      do j=1,n
        indx(j)=j
      enddo
      jstack=0
      l=1
      ir=n
    1 if(ir-l.lt.m) then
        do j=l+1,ir
          indxt=indx(j)
          a=arr(indxt)
          do i=j-1,1,-1
            if(arr(indx(i)).le.a) goto 2
            indx(i+1)=indx(i)
          enddo
          i=0
    2     indx(i+1)=indxt
        enddo
        if (jstack.eq.0) return
        ir=istack(jstack)
        l=istack(jstack-1)
        jstack=jstack-2
      else
        k=(l+ir)/2
        itemp=indx(k)
        indx(k)=indx(l+1)
        indx(l+1)=itemp
        if(arr(indx(l+1)).gt.arr(indx(ir))) then
          itemp=indx(l+1)
          indx(l+1)=indx(ir)
          indx(ir)=itemp
        endif
        if(arr(indx(l)).gt.arr(indx(ir))) then
          itemp=indx(l)
          indx(l)=indx(ir)
          indx(ir)=itemp
        endif
        if(arr(indx(l+1)).gt.arr(indx(l))) then
          itemp=indx(l+1)
          indx(l+1)=indx(l)
          indx(l)=itemp
        endif
        i=l+1
        j=ir
        indxt=indx(l)
        a=arr(indxt)
    3   continue
        i=i+1
        if(arr(indx(i)).lt.a) goto 3
    4   continue
        j=j-1
        if(arr(indx(j)).gt.a) goto 4
        if(j.lt.i) goto 5
        itemp=indx(i)
        indx(i)=indx(j)
        indx(j)=itemp
        goto 3
    5   indx(l)=indx(j)
        indx(j)=indxt
        jstack=jstack+2
        if(jstack.gt.nstack) then
          print *,'*** nstack too small in indexx ***'
          stop
        endif
        if(ir-i+1.ge.j-l) then
          istack(jstack)=ir
          istack(jstack-1)=i
          ir=j-1
        else
          istack(jstack)=j-1
          istack(jstack-1)=l
          l=i
        endif
      endif
      goto 1

      end

end program

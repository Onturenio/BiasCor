

	parameter(nn=5000,nts=10000,spval=9e10)
	dimension f(nn,nts),ia(4),nd(nn)
	dimension  nmax95(nn),nmax50(nn),nmax05(nn)
	character*200 inputfile,outputfile



!	write(*,*)' inputfile,outputfile'
!	read(*,*)inputfile,outputfile
	read(*,*)inputfile

	open(10,file=inputfile,action='read')
	!open(10,file=inputfile,form='unformatted')
	!open(20,file=outputfile,form='unformatted')
	
  !	j=0
  ! 10	continue
  !!	read(10,end=999)ia
  !	j=j+1
  !!	read(10)(f(i,j),i=1,ia(4))
  !  ia(4)=10
  !  print*, 'asdf'
  !  read(10,*,end=999)(f(i,j),i=1,ia(4))
  !  print*, 'asdf'
  ! 	goto 10

   do j=1,1000
     read(10,*)(f(1,j))
   enddo

ia(4)=1

	nrec=j

	do 20 j=1,nrec
	do 20 jj=j,nrec
	do 30 i=1,ia(4)
	if (f(i,j).lt.f(i,jj)) goto 30
	a=f(i,j)
	f(i,j)=f(i,jj)
	f(i,jj)=a
 30	continue
 20	continue

	do 50 i=1,ia(4)
	do 55 j=1,nrec
	if (f(i,j).eq.spval) goto 55
	nd(i)=nd(i)+1
 55	continue
	
	nmax95(i)=int(nd(i)*.95)+1
	nmax50(i)=int(nd(i)*.5)+1
	nmax05(i)=int(nd(i)*.05)+1
 50	continue


!	write(20)1,1,1,ia(4)
!	write(20)(f(i,nmax95(i)),i=1,ia(4))
!	write(20)1,1,1,ia(4)
!	write(20)(f(i,nmax50(i)),i=1,ia(4))
!	write(20)1,1,1,ia(4)
!	write(20)(f(i,nmax05(i)),i=1,ia(4))
print*, f(1,nmax95(1))
print*, f(1,nmax50(1))
print*, f(1,nmax05(1))

	stop
	end
	


	
	
